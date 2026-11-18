#!/usr/bin/env bash
set -u

state=$("${SSH_KEY_STATE:-ssh-key-state}" 2>/dev/null || printf 'noagent')
key="${SSH_KEY_STATE_KEY:-$HOME/.ssh/id_ed25519}"

case "$state" in
  loaded)
    printf 'SSH key is already loaded.\n'
    ;;
  noagent)
    printf 'ssh-agent is not reachable.\n'
    ;;
  *)
    if [ ! -f "$key" ]; then
      printf 'No private key at %s.\n' "$key"
    else
      printf 'Unlocking %s\n' "$key"
      SSH_ASKPASS_REQUIRE=never ssh-add "$key"
      rc=$?
      if [ "$rc" -eq 0 ]; then
        printf 'SSH key loaded.\n'
      else
        printf 'ssh-add failed with exit code %s.\n' "$rc"
      fi
    fi
    ;;
esac

"${TMUX_SSH_KEY:-tmux-ssh-key}" --clear >/dev/null 2>&1 || true
"${TMUX_BIN:-tmux}" refresh-client -S >/dev/null 2>&1 || true

printf '\nPress any key to close\n'
read -rn1 || true
