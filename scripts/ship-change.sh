#!/usr/bin/env bash
#
# Ship one OpenSpec change: gate, archive, commit, optionally push.
#
#   scripts/ship-change.sh <change> "<commit subject>" [options]
#
# Options:
#   --host <name>        Gate a nixosConfigurations.<name> toplevel build (repeatable).
#   --home <name>        Gate a homeConfigurations."pim@<name>" build (repeatable).
#                        With neither flag, both default to this machine's hostname.
#   --flake-check        Also run `nix flake check`. Opt-in, not default — see NOTE.
#   --allow-incomplete   Archive with unchecked tasks (they must be justified in the report).
#   --push               Push main after committing. Off by default — see NOTE.
#
# NOTE on `nix flake check`: it currently fails on this repo for a reason unrelated
# to any change being shipped. modules/HOSTS/pesto-pinephone/configuration.nix and
# modules/HOSTS/nix-on-droid-fairphone/configuration.nix both import `../hostsOld/…`,
# a directory since renamed to `_oldHosts/`, so those two flake outputs cannot
# evaluate. A gate that can never go green is worse than no gate, so the real gate
# here is: the flake's own checks, plus an actual build of the configurations the
# change affects. Fix those two paths and `--flake-check` becomes the better gate.
#
# NOTE on pushing: a NixOS config that evaluates and builds is not yet a config that
# boots. The house flow is to `nixos-rebuild switch` first and let the rebuild hook
# push, so pushing is opt-in here rather than the default.

set -euo pipefail

die() { printf 'ship-change: %s\n' "$*" >&2; exit 1; }
step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

[ $# -ge 2 ] || die "usage: scripts/ship-change.sh <change> \"<commit subject>\" [options]"

CHANGE="$1"; shift
SUBJECT="$1"; shift

HOSTS=(); HOMES=(); FLAKE_CHECK=0; ALLOW_INCOMPLETE=0; PUSH=0
while [ $# -gt 0 ]; do
  case "$1" in
    --host) [ $# -ge 2 ] || die "--host needs a value"; HOSTS+=("$2"); shift 2 ;;
    --home) [ $# -ge 2 ] || die "--home needs a value"; HOMES+=("$2"); shift 2 ;;
    --flake-check)      FLAKE_CHECK=1; shift ;;
    --allow-incomplete) ALLOW_INCOMPLETE=1; shift ;;
    --push)             PUSH=1; shift ;;
    *) die "unknown option: $1" ;;
  esac
done

cd "$(git rev-parse --show-toplevel)"

# Pim's global rule: commits carry no attribution to an assistant. Guard the
# subject rather than trusting whatever called this.
case "$SUBJECT" in
  *Co-authored-by:*|*Co-Authored-By:*|*[Cc]laude*|*"Generated with"*)
    die "commit subject contains assistant attribution; rewrite it" ;;
esac

CHANGE_DIR="openspec/changes/$CHANGE"
[ -d "$CHANGE_DIR" ] || die "no such change: $CHANGE_DIR"

if [ ${#HOSTS[@]} -eq 0 ] && [ ${#HOMES[@]} -eq 0 ]; then
  SELF="$(hostname)"
  HOSTS=("$SELF"); HOMES=("$SELF")
  printf 'ship-change: no --host/--home given, gating on %s\n' "$SELF"
fi

SYSTEM="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

step "Gate 1/4: openspec validate"
# `--changes` is a TYPE filter, not a name filter: it validates every change in
# the repo and fails if any is invalid, which would make shipping one change
# hostage to an unrelated broken one. Validate this change by name only.
openspec validate "$CHANGE" --type change

step "Gate 2/4: tasks complete"
TASKS="$CHANGE_DIR/tasks.md"
if [ -f "$TASKS" ]; then
  # `grep -c` exits 1 on no match, which set -e would treat as fatal.
  REMAINING="$(grep -c '^\s*- \[ \]' "$TASKS" || true)"
  if [ "${REMAINING:-0}" -gt 0 ]; then
    [ "$ALLOW_INCOMPLETE" -eq 1 ] \
      || die "$REMAINING unchecked task(s) in $TASKS (pass --allow-incomplete to override)"
    printf 'ship-change: %s unchecked task(s), continuing (--allow-incomplete)\n' "$REMAINING"
  fi
else
  printf 'ship-change: no tasks.md, skipping task check\n'
fi

step "Gate 3/4: flake checks"
nix build ".#checks.$SYSTEM.mipvim" --no-link
[ "$FLAKE_CHECK" -eq 1 ] && nix flake check

step "Gate 4/4: build affected configurations"
for h in "${HOSTS[@]}"; do
  printf -- '--- nixosConfigurations.%s\n' "$h"
  nix build ".#nixosConfigurations.$h.config.system.build.toplevel" --no-link
done
for h in "${HOMES[@]}"; do
  printf -- '--- homeConfigurations."pim@%s"\n' "$h"
  # --impure: some home modules read paths outside the store (e.g. ~/.aws).
  nix build --impure ".#homeConfigurations.\"pim@$h\".activationPackage" --no-link
done

step "Archiving $CHANGE"
ARCHIVE_ARGS=("$CHANGE")
[ "$ALLOW_INCOMPLETE" -eq 1 ] && ARCHIVE_ARGS+=(--yes)
openspec archive "${ARCHIVE_ARGS[@]}"

ARCHIVED="$(ls -1d openspec/changes/archive/*"$CHANGE" 2>/dev/null | tail -1 || true)"
[ -n "$ARCHIVED" ] || die "archive did not produce openspec/changes/archive/*$CHANGE"

step "Committing"
git add -A
git commit -q -m "$SUBJECT" -m "Archived as ${ARCHIVED}."
git --no-pager log --oneline -1

if [ "$PUSH" -eq 1 ]; then
  step "Pushing main"
  git push origin main
else
  printf '\nship-change: not pushing (pass --push to push main)\n'
fi

printf '\nship-change: shipped %s as %s\n' "$CHANGE" "$(basename "$ARCHIVED")"
