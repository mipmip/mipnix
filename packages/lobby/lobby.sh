#!/usr/bin/env bash
set -euo pipefail

LOBBY_JSON="@LOBBY_JSON@"

usage() {
  cat <<'EOF'
usage: lobby                 pick a service and open it (list when not on a terminal)
       lobby list            list all services
       lobby show <name>     show one service
       lobby open <name>     open a service in the browser
       lobby --json          print the registry as JSON
EOF
}

if [ -t 1 ]; then
  c_dim=$'\e[2m'; c_reset=$'\e[0m'
  c_nebula=$'\e[32m'; c_lan=$'\e[0m'; c_public=$'\e[1m'; c_tunnel=$'\e[33m'; c_local=$'\e[90m'
else
  c_dim=""; c_reset=""; c_nebula=""; c_lan=""; c_public=""; c_tunnel=""; c_local=""
fi

rows() {
  jq -r '
    .services | to_entries
    | sort_by(.value.category, .key)
    | .[] | [.value.category, .key, .value.host, .value.access, (.value.url // "no web UI")] | @tsv
  ' "$LOBBY_JSON"
}

access_colour() {
  case "$1" in
    nebula) printf '%s' "$c_nebula" ;;
    lan) printf '%s' "$c_lan" ;;
    public) printf '%s' "$c_public" ;;
    tunnel) printf '%s' "$c_tunnel" ;;
    local) printf '%s' "$c_local" ;;
  esac
}

list() {
  local current="" category key host access url
  while IFS=$'\t' read -r category key host access url; do
    if [ "$category" != "$current" ]; then
      printf '%s%s%s\n' "$c_dim" "${category^^}" "$c_reset"
      current="$category"
    fi
    printf '  %-17s %-12s %s%-8s%s %s\n' "$key" "$host" "$(access_colour "$access")" "$access" "$c_reset" "$url"
  done < <(rows)
}

browsable() {
  jq -r '
    .services | to_entries
    | map(select(.value.url != null and .value.browse != false))
    | sort_by(.value.category, .key)
    | .[] | [.key, .value.host, .value.access, .value.url] | @tsv
  ' "$LOBBY_JSON" | awk -F'\t' '{ printf "%-17s %-12s %-8s %s\n", $1, $2, $3, $4 }'
}

has() {
  jq -e --arg k "$1" '.services | has($k)' "$LOBBY_JSON" > /dev/null
}

suggest() {
  jq -r '.services | keys[]' "$LOBBY_JSON" | awk -v want="$1" '
    function lev(a, b,   i, j, la, lb, d, cost, m) {
      la = length(a); lb = length(b)
      for (i = 0; i <= la; i++) d[i, 0] = i
      for (j = 0; j <= lb; j++) d[0, j] = j
      for (i = 1; i <= la; i++)
        for (j = 1; j <= lb; j++) {
          cost = substr(a, i, 1) == substr(b, j, 1) ? 0 : 1
          m = d[i-1, j] + 1
          if (d[i, j-1] + 1 < m) m = d[i, j-1] + 1
          if (d[i-1, j-1] + cost < m) m = d[i-1, j-1] + cost
          d[i, j] = m
        }
      return d[la, lb]
    }
    index($0, want) == 1 || index(want, $0) == 1 || lev(want, $0) <= 2 { print }
  '
}

unknown() {
  printf 'lobby: no service named "%s"\n' "$1" >&2
  local close
  close="$(suggest "$1" | paste -sd ' ' -)"
  [ -n "$close" ] && printf 'did you mean: %s\n' "$close" >&2
  exit 1
}

show() {
  has "$1" || unknown "$1"
  jq -r --arg k "$1" '
    .services[$k] as $s
    | [["name", $k], ["description", $s.description], ["host", $s.host], ["access", $s.access],
       ["url", ($s.url // "no web UI")], ["category", $s.category], ["source", ($s.source // "unknown")]]
    | .[] | "\(.[0])\t\(.[1])"
  ' "$LOBBY_JSON" | awk -F'\t' '{ printf "%-12s %s\n", $1, $2 }'
}

open_url() {
  if command -v xdg-open > /dev/null; then
    setsid -f xdg-open "$1" > /dev/null 2>&1
  else
    open "$1"
  fi
}

open_service() {
  has "$1" || unknown "$1"
  local url
  url="$(jq -r --arg k "$1" '.services[$k].url // empty' "$LOBBY_JSON")"
  if [ -z "$url" ]; then
    printf 'lobby: %s has no web UI\n' "$1" >&2
    exit 1
  fi
  printf 'opening %s\n' "$url"
  open_url "$url"
}

pick() {
  local line key
  line="$(browsable | gum filter --placeholder "service, host or URL")" || exit 0
  key="$(awk '{ print $1 }' <<< "$line")"
  open_service "$key"
}

case "${1:-}" in
  "")
    if [ -t 0 ] && [ -t 1 ] && command -v gum > /dev/null; then pick; else list; fi ;;
  list) list ;;
  show) [ $# -eq 2 ] || { usage >&2; exit 2; }; show "$2" ;;
  open) [ $# -eq 2 ] || { usage >&2; exit 2; }; open_service "$2" ;;
  --json) cat "$LOBBY_JSON" ;;
  -h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
