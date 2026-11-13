{ pkgs }:
pkgs.writeShellApplication {
  name = "claude-move-project";
  runtimeInputs = with pkgs; [ coreutils gnused jq ];
  text = ''
    usage() {
      echo "usage: claude-move-project [-n] OLD-DIR NEW-DIR" >&2
      exit 2
    }

    die() {
      echo "claude-move-project: $*" >&2
      exit 1
    }

    dry=false
    if [ "''${1:-}" = "-n" ]; then
      dry=true
      shift
    fi
    [ $# -eq 2 ] || usage

    old=$(realpath -e "$1") || die "$1 does not exist"
    new=$(realpath -m "$2")
    [ -d "$old" ] || die "$old is not a directory"
    [ ! -e "$new" ] || die "$new already exists"
    [ -d "$(dirname "$new")" ] || die "$(dirname "$new") does not exist"

    projects="$HOME/.claude/projects"
    state="$HOME/.claude.json"

    encode() {
      printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'
    }

    for proc in /proc/[0-9]*; do
      cwd=$(readlink "$proc/cwd" 2>/dev/null) || continue
      case "$cwd" in
        "$old" | "$old"/*)
          die "process $(basename "$proc") ($(tr '\0' ' ' < "$proc/cmdline" | cut -c1-60)) still runs in $cwd; quit it first"
          ;;
      esac
    done

    paths=("$old")
    if [ -f "$state" ]; then
      while IFS= read -r p; do
        paths+=("$p")
      done < <(jq -r --arg o "$old/" '.projects // {} | keys[] | select(startswith($o))' "$state")
    fi

    moves=()
    for p in "''${paths[@]}"; do
      from="$projects/$(encode "$p")"
      to="$projects/$(encode "$new''${p#"$old"}")"
      if [ -d "$from" ]; then
        [ ! -e "$to" ] || die "$to already exists"
        moves+=("$from" "$to")
      fi
    done

    echo "move  $old"
    echo "  ->  $new"
    for ((i = 0; i < ''${#moves[@]}; i += 2)); do
      echo "move  ''${moves[i]}"
      echo "  ->  ''${moves[i+1]}"
    done
    [ -f "$state" ] && echo "rekey $state: $old and everything under it"

    if $dry; then
      echo "dry run, nothing changed"
      exit 0
    fi

    mv "$old" "$new"
    for ((i = 0; i < ''${#moves[@]}; i += 2)); do
      mv "''${moves[i]}" "''${moves[i+1]}"
    done

    if [ -f "$state" ]; then
      cp "$state" "$state.before-move"
      jq --arg o "$old" --arg n "$new" '
        if .projects then
          .projects |= with_entries(
            if .key == $o then .key = $n
            elif (.key | startswith($o + "/")) then .key = $n + (.key | ltrimstr($o))
            else . end)
        else . end' "$state.before-move" > "$state.tmp"
      mv "$state.tmp" "$state"
    fi

    echo
    echo "done; resume with:"
    echo "  cd $new && claude --resume"
  '';
}
