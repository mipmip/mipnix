#!/usr/bin/env bash
set -u

dir="${XDG_RUNTIME_DIR:-/tmp}/tmux-status"
cache="$dir/drs"
mkdir -p "$dir" 2>/dev/null || true

now=$(date +%s)
count=""
fresh=0
if [ -r "$cache" ]; then
  read -r ts cached < "$cache" || true
  count="${cached:-}"
  if [ -n "${ts:-}" ] && [ -n "$count" ] && [ $((now - ts)) -lt 60 ]; then
    fresh=1
  fi
fi

if [ "$fresh" -eq 0 ]; then
  if out=$("${DRS:-drs}" --list 2>/dev/null); then
    count=$(printf '%s' "$out" | grep -c .)
    tmp="$cache.$$"
    printf '%s %s\n' "$now" "$count" > "$tmp" && mv -f "$tmp" "$cache"
  fi
fi

if [ -n "${count:-}" ] && [ "$count" -gt 0 ] 2>/dev/null; then
  printf '#[fg=colour214]󰊢 %s#[default]' "$count"
fi
