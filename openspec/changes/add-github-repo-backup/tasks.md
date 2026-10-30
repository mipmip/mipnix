## 1. Token

- [x] 1.1 Create a GitHub classic PAT with `repo` and `read:org`, an expiry date, and SSO authorization for the TechNative organizations.
- [x] 1.2 Add `hip-backup-github-token.age` to `secrets/secrets.nix` with recipients pim and dapperehaan, and encrypt the token into it.

## 2. Module

- [x] 2.1 Add a NixOS module `hip-repo-backup` with the `hip-backup` system user and group and `StateDirectory = "hip-backup"`.
- [x] 2.2 Generate `hip/config.yaml` in the store: `base_dir` under the state directory, `clone_vcs: git`, one `github` provider with `clone_protocol: https`, `auth.env: HIP_GITHUB_TOKEN`, `all_owners: true`, `exclude_owners: [ nix-community ]`, `include_forks: false`, `include_archived: true`.
- [x] 2.3 Add a git config for the user with a credential helper that answers from `HIP_GITHUB_TOKEN`.
- [x] 2.4 Add a oneshot service running `hip sync` with `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, the token loaded from the agenix secret, and `git` on its PATH.
- [x] 2.5 Add a daily timer with `Persistent = true` and `RandomizedDelaySec`.

## 3. dapperehaan

- [x] 3.1 Import the module in `modules/HOSTS/dapperehaan-server/configuration.nix`.
- [x] 3.2 Add the `dapperehaan-repos` dataset (`/var/lib/hip-backup/repos`, keep daily 7, weekly 5, monthly 12, yearly unlimited).
- [x] 3.3 `git add` new files, build dapperehaan, and confirm the token is not in the closure.

## 4. Verify on the host

- [ ] 4.1 Deploy with `rme deploy_remote dapperehaan`.
- [ ] 4.2 Start the service once by hand and follow the journal until it finishes.
- [ ] 4.3 Compare the owners under `/var/lib/hip-backup/repos` with `gh api user/orgs`; investigate any organization that has repositories but no checkouts.
- [ ] 4.4 Confirm no fork and no `nix-community` repository was cloned, and checkouts have no `.jj`.
- [ ] 4.5 Check disk use on dapperehaan against the 13 GB estimate.
- [ ] 4.6 Run the `dapperehaan-repos` restic backup once and confirm it appears in Backrest.
