#!/usr/bin/env bash
set -u

key="${SSH_KEY_STATE_KEY:-$HOME/.ssh/id_ed25519}"
pub="$key.pub"

fp=""
if [ -f "$pub" ]; then
  fp=$(ssh-keygen -lf "$pub" 2>/dev/null | awk '{print $2}')
fi

if [ "${1:-}" = "--fingerprint" ]; then
  printf '%s\n' "$fp"
  exit 0
fi

out=$(ssh-add -l 2>/dev/null)
rc=$?

if [ "$rc" -eq 2 ]; then
  printf 'noagent\n'
elif [ -z "$fp" ]; then
  printf 'unloaded\n'
elif ! printf '%s\n' "$out" | grep -qF -- "$fp"; then
  printf 'unloaded\n'
elif timeout 4 ssh-add -T "$pub" >/dev/null 2>&1; then
  printf 'loaded\n'
else
  printf 'stale\n'
fi
