#!/usr/bin/env bash
# Float the current pane into a centred popup, and put it back exactly.
#
# A popup attaches to a session and cannot host a pane that already exists
# elsewhere, so the pane moves: it is swapped into a hidden session that the
# popup attaches to, and a placeholder takes its slot to hold the layout. The
# placeholder is zoomed so the window behind the popup is blank rather than a
# working layout with a hole in it.
#
#   before            floating                 after
#   +----+----+       +-----------+            +----+----+
#   |    | P  |       |placeholder|  window    |    | P  |
#   |    +----+  -->  |  (zoomed) |            |    +----+
#   |    |    |       +-----------+            |    |    |
#   +----+----+       +-----------+  popup     +----+----+
#                     |     P     |  on _float
#                     +-----------+
#
# State lives in global user options rather than in this script, because the
# two halves of the toggle are separate invocations.

set -u

FS=_float

opt() { tmux show -gqv "$1"; }

# Width is remembered across floats. Anything unset or not a number falls back
# to the default rather than propagating into an arithmetic error.
width() {
  local w
  w=$(opt @float_w)
  case "$w" in '' | *[!0-9]*) w=90 ;; esac
  printf '%s' "$w"
}

# Always against the stored outer client: on resize this runs from the popup's
# own client, and opening a popup there would nest it inside the one being
# replaced.
open_popup() {
  tmux display-popup \
    -c "$(opt @float_client)" \
    -w "$(width)%" -h 90% \
    -b rounded \
    -E "TMUX= tmux attach -t =$FS"
}

float_on() {
  local pane client zoomed ph
  pane=$(tmux display -p '#{pane_id}')
  client=$(tmux display -p '#{client_tty}')
  zoomed=$(tmux display -p '#{window_zoomed_flag}')

  # swap-pane works on the real layout, so a window that is already zoomed is
  # unzoomed first and zoomed again on the way back.
  [ "$zoomed" = 1 ] && tmux resize-pane -Z -t "$pane"

  tmux new-session -d -s "$FS" 'sleep infinity'
  # No "=" prefix here: set-option rejects the exact-match form and reports
  # "no such session", silently leaving the status bar on inside the popup.
  # Every other command below takes "=" and is matched exactly.
  tmux set -t "$FS" status off
  ph=$(tmux list-panes -t "=$FS" -F '#{pane_id}' | head -1)

  tmux swap-pane -d -s "$pane" -t "$ph"
  tmux resize-pane -Z -t "$ph"

  tmux set -g @float_pane "$pane"
  tmux set -g @float_placeholder "$ph"
  tmux set -g @float_client "$client"
  tmux set -g @float_zoomed "$zoomed"

  open_popup
}

float_off() {
  local pane ph zoomed remaining where
  pane=$(opt @float_pane)
  ph=$(opt @float_placeholder)
  zoomed=$(opt @float_zoomed)

  if [ -z "$pane" ] || [ -z "$ph" ]; then
    tmux display-message "float: state lost, leaving $FS alone"
    return 1
  fi

  # Where the pane actually is decides whether to swap at all. A refused kill
  # below leaves the pane already back in its window while the options still
  # say floating, and a second toggle that swapped regardless would send it
  # straight back out. The same branch covers a pane the user has since killed.
  where=$(tmux list-panes -a -F '#{pane_id} #{session_name}' |
    awk -v p="$pane" '$1 == p { print $2 }')

  if [ "$where" = "$FS" ]; then
    if [ "$(tmux display -t "$ph" -p '#{window_zoomed_flag}' 2>/dev/null)" = "1" ]; then
      tmux resize-pane -Z -t "$ph"
    fi
    tmux swap-pane -d -s "$pane" -t "$ph"
  fi

  # The one irreversible step, so it is guarded by identity rather than by
  # order: kill-session takes everything in the session with it, and if the
  # swap did not land that is the user's pane and whatever is running in it.
  remaining=$(tmux list-panes -t "=$FS" -F '#{pane_id}' 2>/dev/null | tr -d '\n')
  if [ "$remaining" != "$ph" ]; then
    tmux display-message "float: pane not restored, keeping $FS"
    return 1
  fi

  tmux kill-session -t "=$FS"
  tmux set -gu @float_pane
  tmux set -gu @float_placeholder
  tmux set -gu @float_client
  tmux set -gu @float_zoomed

  [ "$zoomed" = 1 ] && tmux resize-pane -Z -t "$pane"
  return 0
}

# display-popup cannot be resized, so the width changes by closing the popup and
# opening another one.
resize() {
  local step w i
  step=${1:-0}
  tmux has-session -t "=$FS" 2>/dev/null || return 0

  w=$(( $(width) + step ))
  [ "$w" -lt 20 ] && w=20
  [ "$w" -gt 100 ] && w=100
  tmux set -g @float_w "$w"

  tmux detach-client -s "=$FS"

  # Wait for the client to actually go instead of guessing at a sleep. Bounded,
  # so a client that never detaches costs two seconds rather than the session.
  i=0
  while [ "$i" -lt 100 ]; do
    tmux list-clients -t "=$FS" 2>/dev/null | grep -q . || break
    i=$(( i + 1 ))
    sleep 0.02
  done

  open_popup
}

case "${1:-toggle}" in
  toggle)
    if tmux has-session -t "=$FS" 2>/dev/null; then
      float_off
    else
      float_on
    fi
    ;;
  resize)
    shift
    resize "${1:-0}"
    ;;
  *)
    tmux display-message "float: unknown command ${1}"
    exit 2
    ;;
esac
