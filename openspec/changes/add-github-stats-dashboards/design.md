# Design

## Context

dapperehaan runs Grafana and Prometheus from
`modules/services/monitoring/grafana.nix`. Dashboards are JSON files in
`modules/services/monitoring/dashboards/`, provisioned through a `linkFarm`.
Metrics from scripts reach Prometheus through node-exporter's textfile
collector.

PostgreSQL runs on dapperehaan only because `role-devbox` imports `db-psql`.
`hip-repo-backup` is the nearest existing job: a daily oneshot unit with its
own system user, a `Persistent` timer, and the GitHub token loaded through
`LoadCredential`. Restic datasets with a dump step are declared in the host
file, as `dapperehaan-grafana` does with SQLite.

The mockup is at
`/home/pim/Afbeeldingen/Schermafbeeldingen/2026-11-05-113853_hyprshot.png`.

## Goals / Non-Goals

**Goals:**

- One module, `monitoring-github-stats`, that brings its own database, job,
  data source and dashboards, imported by dapperehaan.
- The dashboards work from the first run, including star history.

**Non-Goals:**

- Private repositories, nix-community, alerts.
- Webhooks or refreshing more often than daily.
- Moving existing dashboards off Prometheus.

## Decisions

### PostgreSQL instead of Prometheus

The issue and pull request lists need titles, authors and waiting times, and
star history has to go back further than Prometheus's 90 days. Rows in tables
handle both. Prometheus with the textfile collector was considered: it matches
the existing pattern, but it has no history before the first run and cannot
hold lists with titles without a label explosion.

### The module enables PostgreSQL itself

`services.postgresql.enable`, `ensureDatabases = [ "github_stats" ]` and
`ensureUsers` for `github-stats` (owner) and `grafana` are set in the new
module. Relying on `role-devbox` would break the dashboards if dapperehaan
ever drops that role.

### Peer authentication over the Unix socket

The job runs as system user `github-stats` and Grafana as `grafana`; both
connect to `/run/postgresql` with peer authentication, so there are no
database passwords. The job grants `SELECT` on its tables to `grafana` after
each schema migration, so Grafana can read but not write.

### A Python job using the GraphQL API

The job is a Python script built with `pkgs.writers.writePython3Bin` and the
`requests` and `psycopg` libraries. The GraphQL API returns repositories with
their stargazers (`starredAt`), issues, pull requests and first comments in
far fewer requests than REST. Issues and pull requests come from GraphQL
search per account: all open items, plus items updated since the last
successful run (365 days on the first run). A search window with more than
1,000 results is split in halves. Review requests come from each open pull
request's `reviewRequests`. A first run takes about 380 requests and five
minutes. A shell script with `gh` and
`psql` was considered, but the paging and upserts are clearer in Python.

### Schema

| Table          | Key                    | Contents                                                |
| -------------- | ---------------------- | ------------------------------------------------------- |
| `repos`        | `id`                   | account, name, url, fork, archived, pushed_at, counts   |
| `stargazers`   | `repo_id, login`       | starred_at                                              |
| `items`        | `repo_id, number`      | kind, title, author, author_type, labels, comments,     |
|                |                        | created_at, first_response_at, updated_at, closed_at,   |
|                |                        | merged_at, review_requested                             |
| `snapshots`    | `day, repo_id`         | stars, forks, watchers, open_issues, open_prs           |
| `runs`         | `started_at`           | finished_at, status, requests, rate_remaining           |

Each run writes everything in one transaction: upsert `repos` and `items`,
replace a repository's `stargazers`, insert today's `snapshots` row. A failed
run rolls back, so the previous data stays intact. Items that are no longer
open get `closed_at` set rather than being deleted, which the opened/closed
per week and time to merge panels need. Schema changes are plain SQL files
applied in order at the start of a run.

`author_type` is `owner` when the author is `mipmip`, `bot` when GitHub
reports a bot, and `external` otherwise.

### Accounts come from GitHub, not from Nix

The job lists `mipmip`'s organizations through the API at each run, minus an
exclude list containing `nix-community`. Keeping the list in Nix was
considered, but then a new organization would need a deploy.

### Fine-grained token with public read-only access

A new token in `secrets/github-stats-token.age`, loaded with
`LoadCredential`, as `hip-repo-backup` does. Fine-grained tokens limited to
public repositories need no approval from organization owners. Reusing
`hip-backup-github-token` would work but gives the job more access than it
needs and shares the rate limit with the backup job.

### Grafana

A second provisioned data source of type `grafana-postgresql-datasource`,
uid `github-stats`, with host `/run/postgresql` and database `github_stats`.
The three dashboards are added to the existing `linkFarm`. Each one has an
`account` variable fed by `SELECT DISTINCT account FROM repos`, and links to
the other two at the top, as in the mockup. Repository names in tables link to
the drill-down with the account and repository variables set.

### Backup

The dataset `dapperehaan-github-stats` is declared in the host file next to
`dapperehaan-grafana`, with a `prepareCommand` that runs `pg_dump` as the
`postgres` user into `/var/backups/restic/github-stats.sql` and a
`cleanupCommand` that removes it.

## Risks / Trade-offs

- [GitHub's GraphQL cost limit is reached on a large account] → The job pages
  in batches and logs the remaining budget per run in `runs`; a run that runs
  out of budget fails and keeps the previous data.
- [Repositories with many thousands of stars make the first run long] → Only
  the first run pages through all stargazers; the largest repository has 400
  today, so this is small.
- [Dashboards in JSON drift from the mockup while editing in the Grafana UI]
  → Provisioned dashboards are read-only in Grafana; changes go through the
  repository.
- [The star history curve changes when someone removes a star] → Stargazers
  are replaced per run and the curve is computed from current stars, so a
  removed star disappears from the past as well. This matches what GitHub
  shows; the daily snapshots keep the counts as they were.

## Migration Plan

1. Create the fine-grained token and add `github-stats-token.age`.
2. Deploy dapperehaan; the first run backfills the data.
3. Check the dashboards and run the backup unit once by hand.

Rollback: remove the module import and deploy. The database stays until it
is dropped by hand.
