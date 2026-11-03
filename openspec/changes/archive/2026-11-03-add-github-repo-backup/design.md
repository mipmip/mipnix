## Context

hip (`github:mipmip/hip`, already a flake input) lists repositories through the
GitHub API and `hip sync` clones missing ones and fast-forwards existing ones,
exiting non-zero when any repository fails. dapperehaan is the backup hub: it
holds the Work pool and is the host that runs restic to piethein
(`backup-restic-piethein`, hourly, one restic repository per dataset).

A size survey on 2026-10-30 via the GitHub API:

| Scope                              | Repos | Packed   |
|------------------------------------|-------|----------|
| Non-fork, without nix-community    | 731   | ~6.5 GB  |
| nix-community (non-fork)           | 194   | ~8.1 GB  |
| All forks                          | 181   | ~11.7 GB |

Fourteen organizations returned no repositories, either because they are
empty or because the token used was not SSO-authorized for them.

## Goals / Non-Goals

**Goals:**

- Every non-fork repository of `mipmip` and Pim's organizations (minus
  `nix-community`) has an up-to-date copy on dapperehaan and in restic.
- No manual step on dapperehaan after deploy, apart from creating the token.
- A failing sync is visible as a failed systemd unit.

**Non-Goals:**

- Issues, pull requests, wikis, releases and other GitHub metadata.
- Every branch and tag as in `git clone --mirror`: hip tracks the default
  branch. Restic snapshots are what keep history that vanishes upstream.
- Forges other than GitHub.
- Changing the laptop hip configuration.

## Decisions

- **Scope by `all_owners: true` plus `exclude_owners: [ nix-community ]`.**
  An explicit `owners` list would silently miss organizations joined later.
  Excluding the one large foreign organization keeps the rest automatic.
  `include_forks: false`, `include_archived: true`: forks are 11.7 GB of
  mostly upstream code, while archived repositories are often exactly what is
  no longer anywhere else.
- **Dedicated system user `hip-backup`, state in `/var/lib/hip-backup`.**
  `XDG_CONFIG_HOME` points at a store directory holding the generated
  `hip/config.yaml`, `XDG_CACHE_HOME` and `base_dir` live under the state
  directory. The backup never touches `/home/pim` or pim's own hip config.
- **HTTPS with a token, not SSH.** hip only uses the token for the API, so git
  gets it through a credential helper in the user's git config that reads
  `HIP_GITHUB_TOKEN`. One secret covers listing and cloning, and no SSH key
  has to be registered with GitHub and SSO-authorized for every organization.
- **`clone_vcs: git`.** Nobody works in these checkouts; a jj layer adds
  nothing to a backup.
- **Daily sync, separate from restic.** A daily timer
  (`RandomizedDelaySec`, `Persistent`) keeps the API load low: 731
  repositories per hour would be wasteful. Restic keeps its hourly schedule;
  unchanged files deduplicate, so the extra runs only cost a scan.
- **Restic retention for `dapperehaan-repos`:** daily 7, weekly 5, monthly
  12, yearly unlimited. The sync is daily, so hourly snapshots add nothing.

## Risks / Trade-offs

- A force-push upstream makes the fast-forward fail for that repository on
  every run, so the unit keeps failing. That is the right signal: restic
  still holds the old history, and the checkout needs a manual look.
- The token is a classic PAT with broad `repo` scope stored on a home server.
  Mitigation: agenix with only pim and dapperehaan as recipients, and an
  expiry date with a reminder to rotate.
- The checkouts share dapperehaan's single 210 GB disk with everything else.
  At 13 GB today there is room, but growth is not bounded by this change.
- Organizations without SSO authorization stay invisible without an error
  from hip. Mitigation: a task compares the owners hip discovers with
  `gh api user/orgs` after the first run.

## Open Questions

- None blocking. Notification on failure beyond a failed unit can follow
  separately.
