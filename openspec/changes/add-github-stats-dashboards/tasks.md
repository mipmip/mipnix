# Tasks

## 1. Token and secret

- [x] 1.1 Create a fine-grained GitHub token with public repositories read-only access (pim does this), add it as `secrets/github-stats-token.age` and register it in `secrets/secrets.nix` for dapperehaan; verify `agenix -d secrets/github-stats-token.age` returns the token
- [ ] 1.2 Verify the token cannot read a private repository: `curl -H "Authorization: Bearer <token>" https://api.github.com/repos/<owner>/<private-repo>` returns 404

## 2. Database and module skeleton

- [x] 2.1 Create `modules/services/monitoring/github-stats.nix` defining `flake.modules.nixos.monitoring-github-stats` with the `github-stats` system user, `services.postgresql.enable`, `ensureDatabases` and `ensureUsers` for `github-stats` and `grafana`; verify `nix build .#nixosConfigurations.dapperehaan.config.system.build.toplevel` succeeds
- [x] 2.2 Write the schema as ordered SQL files (`repos`, `stargazers`, `items`, `snapshots`, `runs`) with `SELECT` granted to `grafana`; verify they apply cleanly to an empty database with `psql -f`

## 3. Fetch job

- [x] 3.1 Write the Python job: list `mipmip` and its organizations minus `nix-community`, fetch public non-private repositories through GraphQL, and upsert `repos`; verify against the API that the repository count matches `gh` for two organizations
- [x] 3.2 Add stargazers with `starredAt`, replaced per repository per run; verify the summed stars equal the sum of `stargazers_count` over the collected repositories
- [x] 3.3 Add open issues and pull requests with author type, labels, comments and first response time, mark items no longer open with `closed_at`, and keep pull requests merged in the last 365 days; verify one known open issue and one merged pull request appear with the right fields
- [x] 3.4 Add review requests from each open pull request's `reviewRequests`; verify the count matches the GitHub search page
- [x] 3.5 Write today's `snapshots` rows and a `runs` row, all in one transaction that rolls back on failure; verify running the job with an invalid token leaves the tables unchanged and the unit failed
- [ ] 3.6 Add the `github-stats` service (oneshot, `LoadCredential` for the token) and a daily `Persistent` timer; verify `systemctl list-timers github-stats` shows the next run and `systemctl start github-stats` succeeds on dapperehaan

## 4. Grafana

- [ ] 4.1 Provision the `github-stats` PostgreSQL data source in `grafana.nix` over `/run/postgresql`; verify "Save & test" in Grafana succeeds and the `grafana` role cannot `INSERT`
- [ ] 4.2 Build the Stargazers overview dashboard JSON per the mockup and spec, add it to the `linkFarm`; verify total stars, stars per account and the cumulative graph show real data after deploy
- [ ] 4.3 Build the Pull requests & issues dashboard JSON; verify the needs-attention table lists the oldest unanswered external items with links to GitHub
- [ ] 4.4 Build the Repository drill-down dashboard JSON with account and repository variables; verify clicking a repository in the overview opens its drill-down with matching star count
- [ ] 4.5 Add the shared Account filter and the links between the three dashboards; verify selecting `quiqr` limits every panel to quiqr's repositories

## 5. Backup

- [ ] 5.1 Add the `dapperehaan-github-stats` dataset with `pg_dump` prepare and cleanup commands and 7/5/12 retention in `modules/HOSTS/dapperehaan-server/configuration.nix`; verify a manual run of the restic unit creates a snapshot and leaves no dump file behind
- [ ] 5.2 Restore the latest snapshot into a scratch database and verify its row counts match `github_stats`

## 6. Integration

- [ ] 6.1 Import `monitoring-github-stats` in dapperehaan, deploy, and verify after the first timer run that all three dashboards load without errors and the lobby entry for Grafana still works
