# Proposal

## Why

Pim's public work is spread over the `mipmip` GitHub account and dozens of
organizations, with more than a thousand repositories between them. There is
no single place that shows how many stars that work has, how that grows, or
which pull requests and issues are waiting for an answer. Grafana on
dapperehaan already shows host health and backups, so GitHub stats can live
next to them.

## What Changes

- A daily job on dapperehaan fetches the public repositories of `mipmip` and
  of every organization `mipmip` belongs to, except `nix-community`, from the
  GitHub API and stores them in a new PostgreSQL database `github_stats`.
- Per repository it stores the stars with the date each star was given, the
  open issues and pull requests, and a daily snapshot of the counts (stars,
  forks, watchers, open issues, open pull requests).
- Star history is backfilled from GitHub on the first run, so the dashboards
  show the full history from the start.
- The job authenticates with a new fine-grained GitHub token that can only
  read public repositories, stored as an agenix secret.
- Grafana gets a PostgreSQL data source for `github_stats` and three
  provisioned dashboards: Stargazers overview, Pull requests & issues, and
  Repository drill-down, laid out as in the mockup.
- The `github_stats` database is backed up to piethein as a new restic
  dataset `dapperehaan-github-stats`, from a `pg_dump` taken before each run.

## Capabilities

### New Capabilities

- `github-stats`: collecting public GitHub statistics for pim's account and
  organizations into PostgreSQL on dapperehaan, showing them in Grafana, and
  backing the data up.

### Modified Capabilities

- `host-backups`: the configured backup targets for dapperehaan gain the
  `github_stats` database dump.

## Impact

- `modules/services/monitoring/`: new module for the fetch job and database,
  new data source and three dashboard JSON files in `grafana.nix` and
  `dashboards/`.
- `modules/HOSTS/dapperehaan-server/configuration.nix`: imports the module and
  adds the `dapperehaan-github-stats` dataset.
- `secrets/`: new `github-stats-token.age`, registered in `secrets.nix`.
- New restic repository on piethein for `dapperehaan-github-stats`.
- GitHub API use: a few hundred requests per daily run, under the 5,000 per
  hour limit for an authenticated token.
