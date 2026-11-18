#!/usr/bin/env bash
set -u

dir="${XDG_RUNTIME_DIR:-/tmp}/tmux-status"
cache="$dir/ssh-key"
mkdir -p "$dir" 2>/dev/null || true

if [ "${1:-}" = "--clear" ]; then
  rm -f "$cache"
  exit 0
fi

now=$(date +%s)
state=""
if [ -r "$cache" ]; then
  read -r ts cached < "$cache" || true
  if [ -n "${ts:-}" ] && [ -n "${cached:-}" ] && [ $((now - ts)) -lt 5 ]; then
    state="$cached"
  fi
fi

if [ -z "$state" ]; then
  state=$("${SSH_KEY_STATE:-ssh-key-state}" 2>/dev/null || printf 'noagent')
  case "$state" in
    loaded|unloaded|stale|noagent) ;;
    *) state=noagent ;;
  esac
  tmp="$cache.$$"
  printf '%s %s\n' "$now" "$state" > "$tmp" && mv -f "$tmp" "$cache"
fi

case "$state" in
  loaded)
    icon='󰿆'
    color='colour46'
    ;;
  unloaded)
    icon='󰌾'
    color='colour214'
    ;;
  stale)
    icon='󰦝'
    color='colour196'
    ;;
  *)
    icon='󰗤'
    color='colour244'
    ;;
esac

printf '#[fg=%s]%s#[default]' "$color" "$icon"
