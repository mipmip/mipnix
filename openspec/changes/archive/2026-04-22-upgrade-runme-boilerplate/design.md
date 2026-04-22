## Context

RUNME.sh currently has 15 commands in a single 650-line file. The v2.0.0 RUNME.sh framework adds `RUNME.d/` auto-sourcing: any `*.sh` file in `RUNME.d/` is sourced before `runme` is called, so `make_command` registrations in those files work transparently.

## Goals / Non-Goals

**Goals:**
- Upgrade to v2.0.0 boilerplate
- Split commands into logical files under `RUNME.d/`
- Keep shared helpers accessible to all command files

**Non-Goals:**
- Changing any command behavior
- Renaming commands

## Decisions

**1. Shared helpers stay in RUNME.sh**

`with_age_identity`, `check_untracked`, `_nebula_ips_from_certs`, `next_free_nebula_ip`, `show_nebula_ip_allocation` are used by multiple commands. They stay in RUNME.sh itself (sourced before RUNME.d/ files? No — RUNME.d/ is sourced first by the boilerplate). So helpers must go in a RUNME.d/ file that sorts first alphabetically.

Solution: put helpers in `RUNME.d/00-helpers.sh` to ensure they're sourced before command files.

**2. File grouping by concern**

| File | Commands |
|------|----------|
| `RUNME.d/00-helpers.sh` | `with_age_identity`, `check_untracked`, `_nebula_ips_from_certs`, `next_free_nebula_ip`, `show_nebula_ip_allocation` |
| `RUNME.d/nix.sh` | `nix_clean`, `nix_clean_yesterday`, `nix_optimise` |
| `RUNME.d/git.sh` | `git_sync_machine` |
| `RUNME.d/system.sh` | `up_home`, `up_machine`, `reload_tmux` |
| `RUNME.d/aws.sh` | `setup_aws_key`, `txn_aws_update`, `copy_aws_other_accounts` |
| `RUNME.d/secrets.sh` | `rekey`, `copy_privkey_to_remote` |
| `RUNME.d/nebula.sh` | `nebula_hosts`, `new_nebula_node` |
| `RUNME.d/host.sh` | `new_host` |

**3. `EXTRA_ARG=$2` stays in RUNME.sh**

This is a global used by `git_sync_machine` and set by callers. It stays in the main file alongside the boilerplate.

**4. New boilerplate**

```bash
#!/usr/bin/env bash
#(C)2019-2026 Pim Snel - https://github.com/mipmip/RUNME.sh
CMDS=(); DESC=(); NARGS=$#; ARG1=$1;make_command(){ CMDS+=($1);DESC+=("$2");};usage(){ printf "\nUsage: %s [command]\n\nCommands:\n" $0;line="              ";for ((i=0;i<=$((${#CMDS[*]}-1));i++));do printf "  %s %s ${DESC[$i]}\n" ${CMDS[$i]} "${line:${#CMDS[$i]}}";done;echo;};RUNME_DIR="$(cd "$(dirname "$0")" && pwd)";if [ -d "$RUNME_DIR/RUNME.d" ]; then for _f in "$RUNME_DIR/RUNME.d"/*.sh; do [ -f "$_f" ] && source "$_f"; done;fi;runme(){ if test $NARGS -eq 1; then eval "$ARG1"||usage;else usage;fi;}
```

Note: shebang changes from `#!/usr/bin/env sh` to `#!/usr/bin/env bash` (the script already uses bash features like arrays and `[[ ]]`).

## Risks / Trade-offs

- [File ordering matters] → Prefix helpers with `00-` to guarantee load order
- [ALLARGS no longer available] → The v2 boilerplate drops `ALLARGS`. `copy_privkey_to_remote` uses `${ALLARGS[1]}`. Replace with `$2` or re-add `ALLARGS` to helpers.
