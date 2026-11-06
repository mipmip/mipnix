import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import psycopg
import requests

API = "https://api.github.com/graphql"
OWNER = os.environ.get("GITHUB_STATS_OWNER", "mipmip")
EXCLUDE = set(os.environ.get("GITHUB_STATS_EXCLUDE", "nix-community").split())
SCHEMA_DIR = Path(os.environ["GITHUB_STATS_SCHEMA"])
READER = os.environ.get("GITHUB_STATS_READER", "grafana")
BACKFILL_DAYS = 365
SEARCH_LIMIT = 1000


class GitHub:
    def __init__(self, token):
        self.session = requests.Session()
        self.session.headers["Authorization"] = f"Bearer {token}"
        self.requests = 0
        self.remaining = None

    def query(self, query, **variables):
        self.requests += 1
        response = self.session.post(API, json={"query": query, "variables": variables}, timeout=60)
        response.raise_for_status()
        body = response.json()
        if body.get("errors"):
            raise RuntimeError(body["errors"])
        self.remaining = body["data"].get("rateLimit", {}).get("remaining", self.remaining)
        return body["data"]

    def pages(self, query, path, **variables):
        cursor = None
        while True:
            data = self.query(query, after=cursor, **variables)
            connection = data
            for key in path:
                connection = connection[key]
            yield from connection.get("nodes", connection.get("edges")) or []
            if not connection["pageInfo"]["hasNextPage"]:
                return
            cursor = connection["pageInfo"]["endCursor"]


ORGS = """
query($after: String) {
  rateLimit { remaining }
  viewer { organizations(first: 100, after: $after) {
    pageInfo { hasNextPage endCursor }
    nodes { login }
  } }
}
"""

REPOS = """
query($login: String!, $after: String) {
  rateLimit { remaining }
  repositoryOwner(login: $login) {
    repositories(first: 100, after: $after, privacy: PUBLIC, ownerAffiliations: [OWNER]) {
      pageInfo { hasNextPage endCursor }
      nodes {
        databaseId name url isFork isArchived pushedAt stargazerCount forkCount
        watchers { totalCount }
        issues(states: OPEN) { totalCount }
        pullRequests(states: OPEN) { totalCount }
      }
    }
  }
}
"""

STARGAZERS = """
query($owner: String!, $name: String!, $after: String) {
  rateLimit { remaining }
  repository(owner: $owner, name: $name) {
    stargazers(first: 100, after: $after) {
      pageInfo { hasNextPage endCursor }
      edges { starredAt node { login } }
    }
  }
}
"""

ITEM_FIELDS = """
number title url createdAt updatedAt closedAt
author { login __typename }
repository { databaseId }
labels(first: 20) { nodes { name } }
comments(first: 20) { totalCount nodes { createdAt author { login } } }
"""

SEARCH = """
query($q: String!, $after: String) {
  rateLimit { remaining }
  search(query: $q, type: ISSUE, first: 50, after: $after) {
    issueCount
    pageInfo { hasNextPage endCursor }
    nodes {
      __typename
      ... on Issue { %s }
      ... on PullRequest {
        %s
        mergedAt
        reviews(first: 20) { nodes { submittedAt author { login } } }
        reviewRequests(first: 20) { nodes { requestedReviewer { ... on User { login } } } }
      }
    }
  }
}
""" % (ITEM_FIELDS, ITEM_FIELDS)


def accounts(github):
    orgs = [org["login"] for org in github.pages(ORGS, ["viewer", "organizations"])]
    return [OWNER] + sorted(login for login in orgs if login not in EXCLUDE)


def author_type(author):
    if author is None:
        return "external"
    if author["__typename"] == "Bot":
        return "bot"
    if author["login"] == OWNER:
        return "owner"
    return "external"


def first_response(node):
    author = (node.get("author") or {}).get("login")
    times = [
        c["createdAt"]
        for c in node["comments"]["nodes"]
        if (c.get("author") or {}).get("login") not in (author, None)
    ]
    times += [
        r["submittedAt"]
        for r in (node.get("reviews") or {}).get("nodes", [])
        if r.get("submittedAt") and (r.get("author") or {}).get("login") not in (author, None)
    ]
    return min(times) if times else None


def item_row(node):
    requested = [
        (r.get("requestedReviewer") or {}).get("login")
        for r in (node.get("reviewRequests") or {}).get("nodes", [])
    ]
    return (
        node["repository"]["databaseId"],
        node["number"],
        "pr" if node["__typename"] == "PullRequest" else "issue",
        node["title"],
        node["url"],
        (node.get("author") or {}).get("login"),
        author_type(node.get("author")),
        [label["name"] for label in node["labels"]["nodes"]],
        node["comments"]["totalCount"],
        node["createdAt"],
        node["updatedAt"],
        first_response(node),
        node["closedAt"],
        node.get("mergedAt"),
        node["closedAt"] is None and OWNER in requested,
    )


def qualifier(login):
    return f"user:{login}" if login == OWNER else f"org:{login}"


def search(github, query):
    count = github.query(SEARCH, q=query, after=None)["search"]["issueCount"]
    if count > SEARCH_LIMIT:
        raise RuntimeError(f"search '{query}' has {count} results, more than {SEARCH_LIMIT}")
    return [node for node in github.pages(SEARCH, ["search"], q=query) if node]


def search_updated(github, login, start, end):
    query = f"{qualifier(login)} is:public updated:{start.isoformat()}..{end.isoformat()}"
    count = github.query(SEARCH, q=query, after=None)["search"]["issueCount"]
    if count > SEARCH_LIMIT and end > start:
        middle = start + (end - start) / 2
        return search_updated(github, login, start, middle) + search_updated(
            github, login, middle + timedelta(days=1), end
        )
    return search(github, query)


def migrate(conn):
    conn.execute("CREATE TABLE IF NOT EXISTS schema_migrations (name text PRIMARY KEY)")
    applied = {row[0] for row in conn.execute("SELECT name FROM schema_migrations")}
    for path in sorted(SCHEMA_DIR.glob("*.sql")):
        if path.name not in applied:
            conn.execute(path.read_text())
            conn.execute("INSERT INTO schema_migrations VALUES (%s)", (path.name,))
    conn.execute(f'GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{READER}"')


def collect(github, conn, now):
    last = conn.execute("SELECT max(started_at) FROM runs WHERE status = 'ok'").fetchone()[0]
    since = (last - timedelta(days=1)) if last else now - timedelta(days=BACKFILL_DAYS)

    repos = []
    for login in accounts(github):
        for repo in github.pages(REPOS, ["repositoryOwner", "repositories"], login=login):
            repos.append((login, repo))

    seen = set()
    for login, r in repos:
        seen.add(r["databaseId"])
        conn.execute(
            """
            INSERT INTO repos VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE SET
              account = EXCLUDED.account, name = EXCLUDED.name, url = EXCLUDED.url,
              is_fork = EXCLUDED.is_fork, is_archived = EXCLUDED.is_archived,
              pushed_at = EXCLUDED.pushed_at, stars = EXCLUDED.stars, forks = EXCLUDED.forks,
              watchers = EXCLUDED.watchers, open_issues = EXCLUDED.open_issues,
              open_prs = EXCLUDED.open_prs, seen_at = EXCLUDED.seen_at
            """,
            (
                r["databaseId"], login, r["name"], r["url"], r["isFork"], r["isArchived"],
                r["pushedAt"], r["stargazerCount"], r["forkCount"], r["watchers"]["totalCount"],
                r["issues"]["totalCount"], r["pullRequests"]["totalCount"], now,
            ),
        )
        conn.execute(
            """
            INSERT INTO snapshots VALUES (%s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (day, repo_id) DO UPDATE SET
              stars = EXCLUDED.stars, forks = EXCLUDED.forks, watchers = EXCLUDED.watchers,
              open_issues = EXCLUDED.open_issues, open_prs = EXCLUDED.open_prs
            """,
            (
                now.date(), r["databaseId"], r["stargazerCount"], r["forkCount"],
                r["watchers"]["totalCount"], r["issues"]["totalCount"], r["pullRequests"]["totalCount"],
            ),
        )

        conn.execute("DELETE FROM stargazers WHERE repo_id = %s", (r["databaseId"],))
        if r["stargazerCount"]:
            stars = [
                (r["databaseId"], edge["node"]["login"], edge["starredAt"])
                for edge in github.pages(
                    STARGAZERS, ["repository", "stargazers"], owner=login, name=r["name"]
                )
            ]
            if not stars:
                raise RuntimeError(
                    f"{login}/{r['name']} has {r['stargazerCount']} stars but GitHub listed none; "
                    "the token needs the public_repo scope"
                )
            with conn.cursor() as cur:
                cur.executemany("INSERT INTO stargazers VALUES (%s, %s, %s) ON CONFLICT DO NOTHING", stars)

    conn.execute("DELETE FROM repos WHERE NOT (id = ANY(%s))", (list(seen),))

    nodes = {}
    for login in {login for login, r in repos if r["issues"]["totalCount"] or r["pullRequests"]["totalCount"]}:
        for node in search(github, f"{qualifier(login)} is:public is:open"):
            nodes[node["url"]] = node
    for login in {login for login, _ in repos}:
        for node in search_updated(github, login, since.date(), now.date()):
            nodes[node["url"]] = node

    rows = [item_row(node) for node in nodes.values() if node["repository"]["databaseId"] in seen]
    with conn.cursor() as cur:
        cur.executemany(
            """
            INSERT INTO items VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (repo_id, number) DO UPDATE SET
              kind = EXCLUDED.kind, title = EXCLUDED.title, url = EXCLUDED.url,
              author = EXCLUDED.author, author_type = EXCLUDED.author_type,
              labels = EXCLUDED.labels, comments = EXCLUDED.comments,
              updated_at = EXCLUDED.updated_at, first_response_at = EXCLUDED.first_response_at,
              closed_at = EXCLUDED.closed_at, merged_at = EXCLUDED.merged_at,
              review_requested = EXCLUDED.review_requested
            """,
            rows,
        )

    open_keys = [(row[0], row[1]) for row in rows if row[12] is None]
    conn.execute(
        """
        UPDATE items SET closed_at = %s, review_requested = false
        WHERE closed_at IS NULL
          AND (repo_id, number) NOT IN (SELECT * FROM unnest(%s::bigint[], %s::int[]))
        """,
        (now, [k[0] for k in open_keys], [k[1] for k in open_keys]),
    )


def main():
    token = Path(os.environ["CREDENTIALS_DIRECTORY"], "github-token").read_text().strip()
    github = GitHub(token)
    now = datetime.now(timezone.utc)
    with psycopg.connect(os.environ.get("GITHUB_STATS_DSN", "dbname=github_stats")) as conn:
        with conn.transaction():
            migrate(conn)
        try:
            with conn.transaction():
                collect(github, conn, now)
                conn.execute(
                    "INSERT INTO runs VALUES (%s, %s, 'ok', %s, %s)",
                    (now, datetime.now(timezone.utc), github.requests, github.remaining),
                )
        except Exception as error:
            with conn.transaction():
                conn.execute(
                    "INSERT INTO runs VALUES (%s, %s, 'failed', %s, %s)",
                    (now, datetime.now(timezone.utc), github.requests, github.remaining),
                )
            print(f"github-stats: {error}", file=sys.stderr)
            sys.exit(1)
    print(f"github-stats: ok, {github.requests} requests, {github.remaining} remaining")


if __name__ == "__main__":
    main()
