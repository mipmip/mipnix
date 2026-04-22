## 1. Boilerplate upgrade

- [x] 1.1 Replace the v1 boilerplate in RUNME.sh with the v2.0.0 boilerplate (includes RUNME_DIR and RUNME.d/ auto-sourcing)
- [x] 1.2 Change shebang from `#!/usr/bin/env sh` to `#!/usr/bin/env bash`
- [x] 1.3 Keep `EXTRA_ARG=$2` in RUNME.sh

## 2. Create RUNME.d/ files

- [x] 2.1 Create `RUNME.d/00-helpers.sh` with shared helpers: `with_age_identity`, `check_untracked`, `_nebula_ips_from_certs`, `next_free_nebula_ip`, `show_nebula_ip_allocation`
- [x] 2.2 Create `RUNME.d/nix.sh` with `nix_clean`, `nix_clean_yesterday`, `nix_optimise`
- [x] 2.3 Create `RUNME.d/git.sh` with `git_sync_machine`
- [x] 2.4 Create `RUNME.d/system.sh` with `up_home`, `up_machine`, `reload_tmux`
- [x] 2.5 Create `RUNME.d/aws.sh` with `setup_aws_key`, `txn_aws_update`, `copy_aws_other_accounts`
- [x] 2.6 Create `RUNME.d/secrets.sh` with `rekey`, `copy_privkey_to_remote`
- [x] 2.7 Create `RUNME.d/nebula.sh` with `nebula_hosts`, `new_nebula_node`
- [x] 2.8 Create `RUNME.d/host.sh` with `new_host`

## 3. Cleanup

- [x] 3.1 Remove all moved commands and helpers from RUNME.sh (keep only boilerplate, EXTRA_ARG, and `runme` call)
- [x] 3.2 Replace `${ALLARGS[1]}` in `copy_privkey_to_remote` with `$2` — kept ALLARGS instead since v2 boilerplate loses positional args in eval context
- [x] 3.3 Verify `./RUNME.sh` shows all 15 commands in usage output
