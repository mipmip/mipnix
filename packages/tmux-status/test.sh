#!/usr/bin/env bash
set -eu

here=$(cd "$(dirname "$0")" && pwd)
state_script=${SSH_KEY_STATE_SCRIPT:-$(cd "$here/../ssh-key-state" && pwd)/ssh-key-state.sh}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

export HOME="$work/home"
export XDG_RUNTIME_DIR="$work/runtime"
export PATH="$work/bin:$PATH"
mkdir -p "$HOME/.ssh" "$work/bin" "$XDG_RUNTIME_DIR"
printf 'ssh-ed25519 AAAA test\n' > "$HOME/.ssh/id_ed25519.pub"
printf 'private\n' > "$HOME/.ssh/id_ed25519"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

fix_shebang() {
  sed -i "1s|.*|#!$BASH|" "$@"
}

expect() {
  [ "$2" = "$3" ] || fail "$1: want [$2], got [$3]"
}

cat > "$work/bin/ssh-keygen" <<'EOF'
#!/usr/bin/env bash
printf '256 SHA256:abc test (ED25519)\n'
EOF

cat > "$work/bin/ssh-add" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  -l)
    [ "${TEST_AGENT:-ok}" = noagent ] && exit 2
    [ "${TEST_AGENT:-ok}" = empty ] && exit 1
    printf '256 SHA256:abc agent (ED25519)\n'
    ;;
  -T)
    [ "${TEST_SIGN:-ok}" = ok ] || exit 1
    ;;
esac
EOF
chmod +x "$work/bin/ssh-keygen" "$work/bin/ssh-add"
fix_shebang "$work/bin/ssh-keygen" "$work/bin/ssh-add"

state() {
  TEST_AGENT="${1:-ok}" TEST_SIGN="${2:-ok}" bash "$state_script"
}

expect "loaded" loaded "$(state)"
expect "fingerprint" "SHA256:abc" "$(bash "$state_script" --fingerprint)"
expect "empty-agent" unloaded "$(state empty)"
expect "no-agent" noagent "$(state noagent)"
expect "stale" stale "$(state ok fail)"

mv "$HOME/.ssh/id_ed25519.pub" "$work/pub"
expect "missing-pubkey" unloaded "$(state)"
mv "$work/pub" "$HOME/.ssh/id_ed25519.pub"

cat > "$work/bin/ssh-key-state" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${TEST_STATE-loaded}"
EOF
chmod +x "$work/bin/ssh-key-state"
fix_shebang "$work/bin/ssh-key-state"

segment() {
  TEST_STATE="$1" bash "$here/tmux-ssh-key.sh"
}

case "$(segment '')" in
  *"󰗤"*) ;;
  *) fail "unknown state should fall back to noagent" ;;
esac
bash "$here/tmux-ssh-key.sh" --clear
case "$(segment loaded)" in
  *colou?46*"󰿆"*) ;;
  *) fail "loaded segment" ;;
esac
case "$(segment unloaded)" in
  *"󰿆"*) ;;
  *) fail "key state was not cached" ;;
esac
bash "$here/tmux-ssh-key.sh" --clear
case "$(segment unloaded)" in
  *"󰌾"*) ;;
  *) fail "unloaded segment after clear" ;;
esac
printf '1 loaded\n' > "$XDG_RUNTIME_DIR/tmux-status/ssh-key"
case "$(segment unloaded)" in
  *"󰌾"*) ;;
  *) fail "old cache was not refreshed" ;;
esac
rm -rf "$XDG_RUNTIME_DIR/tmux-status"

export DRS_CALLS="$work/drs-calls"
: > "$DRS_CALLS"
cat > "$work/bin/drs" <<'EOF'
#!/usr/bin/env bash
printf 'call\n' >> "$DRS_CALLS"
[ "${TEST_DRS_FAIL:-0}" = 1 ] && exit 1
n=${TEST_DRS_COUNT:-2}
i=0
while [ "$i" -lt "$n" ]; do
  printf 'repo%s\n' "$i"
  i=$((i + 1))
done
EOF
chmod +x "$work/bin/drs"
fix_shebang "$work/bin/drs"

dirty() {
  TEST_DRS_COUNT="${1:-2}" TEST_DRS_FAIL="${2:-0}" bash "$here/tmux-dirty-repos.sh"
}

case "$(dirty)" in
  *"󰊢 2"*) ;;
  *) fail "dirty count" ;;
esac
[ "$(wc -l < "$DRS_CALLS")" -eq 1 ] || fail "drs was called more than once"
case "$(dirty)" in
  *"󰊢 2"*) ;;
  *) fail "dirty cache" ;;
esac
[ "$(wc -l < "$DRS_CALLS")" -eq 1 ] || fail "drs ran inside the cache window"
rm -rf "$XDG_RUNTIME_DIR/tmux-status"
[ -z "$(dirty 0)" ] || fail "zero count should be hidden"
printf '%s 2\n' "$(date +%s)" > "$XDG_RUNTIME_DIR/tmux-status/drs"
case "$(dirty 0 1)" in
  *"󰊢 2"*) ;;
  *) fail "failed scan did not keep the last count" ;;
esac
rm -rf "$XDG_RUNTIME_DIR/tmux-status"

export SSH_ADD_CALLS="$work/ssh-add-calls"
export SSH_ASKPASS_CALLS="$work/askpass-calls"
export TMUX_CALLS="$work/tmux-calls"
export TMUX_SSH_KEY_CALLS="$work/tmux-ssh-key-calls"
: > "$SSH_ADD_CALLS"
: > "$SSH_ASKPASS_CALLS"
: > "$TMUX_CALLS"
: > "$TMUX_SSH_KEY_CALLS"

cat > "$work/bin/ssh-add" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SSH_ADD_CALLS"
printf '%s\n' "${SSH_ASKPASS_REQUIRE:-unset}" >> "$SSH_ASKPASS_CALLS"
EOF
cat > "$work/bin/tmux" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$TMUX_CALLS"
EOF
cat > "$work/bin/tmux-ssh-key" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$TMUX_SSH_KEY_CALLS"
EOF
chmod +x "$work/bin/ssh-add" "$work/bin/tmux" "$work/bin/tmux-ssh-key"
fix_shebang "$work/bin/ssh-add" "$work/bin/tmux" "$work/bin/tmux-ssh-key"

unlock() {
  TEST_STATE="$1" bash "$here/ssh-key-unlock.sh" < /dev/null
}

case "$(unlock loaded)" in
  *"already loaded"*) ;;
  *) fail "loaded unlock message" ;;
esac
[ ! -s "$SSH_ADD_CALLS" ] || fail "ssh-add ran for a loaded key"

: > "$TMUX_CALLS"
: > "$TMUX_SSH_KEY_CALLS"
case "$(unlock unloaded)" in
  *"SSH key loaded"*) ;;
  *) fail "unloaded unlock" ;;
esac
expect "ssh-add path" "$HOME/.ssh/id_ed25519" "$(cat "$SSH_ADD_CALLS")"
expect "askpass mode" never "$(cat "$SSH_ASKPASS_CALLS")"
expect "tmux refresh" "refresh-client -S" "$(cat "$TMUX_CALLS")"
expect "cache clear" --clear "$(cat "$TMUX_SSH_KEY_CALLS")"

: > "$SSH_ADD_CALLS"
case "$(unlock noagent)" in
  *"not reachable"*) ;;
  *) fail "noagent unlock message" ;;
esac
[ ! -s "$SSH_ADD_CALLS" ] || fail "ssh-add ran without an agent"

mv "$HOME/.ssh/id_ed25519" "$work/key"
case "$(unlock unloaded)" in
  *"No private key"*) ;;
  *) fail "missing key message" ;;
esac
[ ! -s "$SSH_ADD_CALLS" ] || fail "ssh-add ran without a key"
mv "$work/key" "$HOME/.ssh/id_ed25519"

printf 'ok\n'
