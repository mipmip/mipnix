CREATE TABLE repos (
  id bigint PRIMARY KEY,
  account text NOT NULL,
  name text NOT NULL,
  url text NOT NULL,
  is_fork boolean NOT NULL,
  is_archived boolean NOT NULL,
  pushed_at timestamptz,
  stars integer NOT NULL,
  forks integer NOT NULL,
  watchers integer NOT NULL,
  open_issues integer NOT NULL,
  open_prs integer NOT NULL,
  seen_at timestamptz NOT NULL
);

CREATE TABLE stargazers (
  repo_id bigint NOT NULL REFERENCES repos (id) ON DELETE CASCADE,
  login text NOT NULL,
  starred_at timestamptz NOT NULL,
  PRIMARY KEY (repo_id, login)
);

CREATE TABLE items (
  repo_id bigint NOT NULL REFERENCES repos (id) ON DELETE CASCADE,
  number integer NOT NULL,
  kind text NOT NULL CHECK (kind IN ('issue', 'pr')),
  title text NOT NULL,
  url text NOT NULL,
  author text,
  author_type text NOT NULL CHECK (author_type IN ('owner', 'external', 'bot')),
  labels text[] NOT NULL DEFAULT '{}',
  comments integer NOT NULL,
  created_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  first_response_at timestamptz,
  closed_at timestamptz,
  merged_at timestamptz,
  review_requested boolean NOT NULL DEFAULT false,
  PRIMARY KEY (repo_id, number)
);

CREATE TABLE snapshots (
  day date NOT NULL,
  repo_id bigint NOT NULL REFERENCES repos (id) ON DELETE CASCADE,
  stars integer NOT NULL,
  forks integer NOT NULL,
  watchers integer NOT NULL,
  open_issues integer NOT NULL,
  open_prs integer NOT NULL,
  PRIMARY KEY (day, repo_id)
);

CREATE TABLE runs (
  started_at timestamptz PRIMARY KEY,
  finished_at timestamptz NOT NULL,
  status text NOT NULL,
  requests integer NOT NULL,
  rate_remaining integer
);

CREATE INDEX items_open ON items (repo_id) WHERE closed_at IS NULL;
CREATE INDEX stargazers_starred_at ON stargazers (starred_at);
