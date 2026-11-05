# Spec Delta

## Purpose

Collect public GitHub statistics for pim's account and organizations on
dapperehaan, show them in Grafana, and keep the collected history safe.

## ADDED Requirements

### Requirement: Collected accounts

The collection SHALL cover the public repositories of the `mipmip` account
and of every organization `mipmip` is a member of, except `nix-community`.
Private repositories SHALL NOT be collected.

#### Scenario: Organization joined

- **WHEN** `mipmip` joins a new organization that has public repositories
- **THEN** its repositories appear in the data after the next daily run, with
  no configuration change

#### Scenario: nix-community excluded

- **WHEN** a daily run completes
- **THEN** no repository owned by `nix-community` is in the data

#### Scenario: Private repository

- **WHEN** an account owns a private repository
- **THEN** that repository is not in the data

### Requirement: Daily refresh

The data SHALL be refreshed once a day by an unattended job on dapperehaan. A
run that is missed while the host is off SHALL run after the host starts.

#### Scenario: Normal day

- **WHEN** a day passes with dapperehaan running
- **THEN** the data is at most one day old

#### Scenario: Host was off

- **WHEN** dapperehaan was off at the scheduled time
- **THEN** the job runs once soon after the host starts

#### Scenario: GitHub unreachable

- **WHEN** the GitHub API fails during a run
- **THEN** the job ends in the failed state and the data from the previous
  run stays intact

### Requirement: Star history

For every collected repository the data SHALL hold each stargazer with the
time the star was given, including stars given before the collection started.

#### Scenario: First run

- **WHEN** the job runs for the first time
- **THEN** the cumulative star count for any past date can be derived from
  the data

#### Scenario: Star removed

- **WHEN** a user removes a star
- **THEN** that star is no longer counted after the next run

### Requirement: Daily snapshots

Each run SHALL record per repository its stars, forks, watchers, open issues
and open pull requests for that day. Snapshots of earlier days SHALL be kept.

#### Scenario: Forks trend

- **WHEN** the job has run on 30 days
- **THEN** the fork count of a repository on each of those days is in the data

### Requirement: Open issues and pull requests

Each run SHALL store the open issues and pull requests of every collected
repository with title, author, author type (owner, external, bot), labels,
comment count, creation time and time of first response by someone other
than the author. Pull requests merged in the last 365 days SHALL also be kept.

#### Scenario: Issue closed

- **WHEN** an open issue is closed on GitHub
- **THEN** it is no longer listed as open after the next run

#### Scenario: Waiting for a response

- **WHEN** an external user opened an issue and nobody else has commented
- **THEN** the issue is in the data without a first response time

### Requirement: Review requests

Each run SHALL store the open pull requests in collected repositories in which
a review is requested from `mipmip`.

#### Scenario: Review requested

- **WHEN** someone requests a review from `mipmip` on a public pull request
- **THEN** it counts as awaiting review after the next run

### Requirement: Read-only public token

The job SHALL authenticate to GitHub with a token that can only read public
repositories. The token SHALL be stored as an agenix secret and SHALL NOT be
readable by other users or appear in the Nix store.

#### Scenario: Token permissions

- **WHEN** the token is used to write to a repository or read a private one
- **THEN** GitHub refuses the request

### Requirement: Dashboards are provisioned

Grafana SHALL have a data source for the collected data and three dashboards
provisioned from the repository: Stargazers overview, Pull requests & issues,
and Repository drill-down. They SHALL link to each other and share an Account
filter.

#### Scenario: Rebuilt host

- **WHEN** dapperehaan's Grafana state directory is empty after a rebuild
- **THEN** the data source and the three dashboards are present after startup

#### Scenario: Account filter

- **WHEN** pim selects an account in the Account filter
- **THEN** every panel on the dashboard shows only that account's repositories

### Requirement: Stargazers overview dashboard

The Stargazers overview SHALL show total stars, stars gained in the last 30
days, repository and organization counts, the most-starred repository,
cumulative stars over time, stars per account, top repositories and the share
of stars per account.

#### Scenario: Totals

- **WHEN** pim opens the Stargazers overview
- **THEN** total stars equals the sum of stars over all collected repositories

#### Scenario: Time range

- **WHEN** pim sets the time range to the last 12 months
- **THEN** the cumulative stars graph covers those 12 months

### Requirement: Pull requests and issues dashboard

The Pull requests & issues dashboard SHALL show open pull requests, open
issues, pull requests awaiting pim's review, median time to merge, median time
to first response, stale items, items opened and closed per week, open items
per account, the oldest items without a response, open issue age and merged
pull requests by author type.

#### Scenario: Needs attention

- **WHEN** pim opens the dashboard
- **THEN** the oldest open items opened by others without a response are
  listed first, each linking to GitHub

#### Scenario: Stale items

- **WHEN** an open item has had no activity for more than 90 days
- **THEN** it counts as stale

### Requirement: Repository drill-down dashboard

The Repository drill-down SHALL show, for one repository chosen by account and
name, its stars, forks, watchers, open issues, open pull requests, last push,
star history, new stars per month and its open issues and pull requests.

#### Scenario: Choosing a repository

- **WHEN** pim selects `mipmip` and `inkscape-cloud-architect`
- **THEN** every panel shows that repository's data

#### Scenario: From the overview

- **WHEN** pim clicks a repository in the top repositories table
- **THEN** the drill-down opens for that repository

### Requirement: Collected data is backed up

The `github_stats` database SHALL be backed up to piethein as the restic
dataset `dapperehaan-github-stats`, from a `pg_dump` taken before each run and
removed afterwards, keeping 7 daily, 5 weekly and 12 monthly snapshots.

#### Scenario: Restoring

- **WHEN** dapperehaan is rebuilt and the latest `dapperehaan-github-stats`
  dump is restored into an empty `github_stats` database
- **THEN** the dashboards show the same history as before, including snapshots
  that GitHub cannot provide again

#### Scenario: Dump removed

- **WHEN** a backup run finishes
- **THEN** no dump file is left on disk
