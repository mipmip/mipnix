{
  ...
}:
{
  # Hostname-derived Hyprland wallpaper. On the first `home-manager switch`
  # (best-effort, guarded) it downloads a dark and a light image for the current
  # hostname and stores them in a mutable dir; `theme-wallpaper` then shows them
  # in replace mode while keeping the dark/light switch. Wikipedia (Wikimedia
  # API) is the primary source, DuckDuckGo an opt-in fallback. See openspec
  # change add-host-wallpaper.
  flake.modules.homeManager.pim-host-wallpaper = { config, lib, pkgs, ... }:
    let
      # Fetch script: resolves the hostname at runtime, and for each mode skips
      # when a committed or already-downloaded image exists, else tries Wikipedia
      # then DuckDuckGo, validates the result is a real raster image, and saves
      # it. Never exits non-zero in a way that would abort activation.
      fetchScript = pkgs.writeShellScriptBin "host-wallpaper-fetch" ''
        set -uo pipefail

        curl=${pkgs.curl}/bin/curl
        jq=${pkgs.jq}/bin/jq
        file=${pkgs.file}/bin/file
        ua="mipnix-host-wallpaper/1.0 (pim@technative.eu)"

        host="$(cat /etc/hostname 2>/dev/null | head -1 | ${pkgs.coreutils}/bin/tr -d '[:space:]')"
        [ -z "$host" ] && host="unknown"
        base="$HOME/.local/share/host-wallpaper"
        committed="$HOME/mipnix/resources/host-wallpapers"
        mkdir -p "$base/dark" "$base/light"

        # Print a validated image URL's bytes to stdout file $1, or fail.
        download() {
          url="$1"; out="$2"
          [ -z "$url" ] && return 1
          tmp="$(${pkgs.coreutils}/bin/mktemp)"
          if ! "$curl" -fsSL -A "$ua" --max-time 30 "$url" -o "$tmp"; then
            rm -f "$tmp"; return 1
          fi
          # Reject HTML/errors/tiny files; require an image mime and >20KB.
          sz=$(${pkgs.coreutils}/bin/stat -c%s "$tmp" 2>/dev/null || echo 0)
          mime=$("$file" -b --mime-type "$tmp" 2>/dev/null || echo none)
          case "$mime" in
            image/*) ;;
            *) rm -f "$tmp"; return 1 ;;
          esac
          if [ "$sz" -lt 20000 ]; then rm -f "$tmp"; return 1; fi
          ${pkgs.coreutils}/bin/mv "$tmp" "$out"
          return 0
        }

        # Wikipedia lead image (arg1=lang). Empty on miss.
        wiki_lead() {
          "$curl" -fsSL -A "$ua" --max-time 15 -G "https://$1.wikipedia.org/w/api.php" \
            --data-urlencode "titles=$host" \
            -d "action=query&prop=pageimages&piprop=original&format=json&redirects=1" 2>/dev/null \
            | "$jq" -r '.query.pages[]?.original.source // empty' 2>/dev/null | head -1
        }

        # Additional image from the page (arg1=lang, arg2=url-to-skip). Empty on miss.
        wiki_other() {
          files=$("$curl" -fsSL -A "$ua" --max-time 15 -G "https://$1.wikipedia.org/w/api.php" \
            --data-urlencode "titles=$host" \
            -d "action=query&prop=images&imlimit=25&format=json&redirects=1" 2>/dev/null \
            | "$jq" -r '.query.pages[]?.images[]?.title // empty' 2>/dev/null \
            | grep -iE '\.(jpg|jpeg|png)$' | grep -viE 'commons-logo|wiki|icon|svg' )
          for f in $files; do
            u=$("$curl" -fsSL -A "$ua" --max-time 15 -G "https://$1.wikipedia.org/w/api.php" \
              --data-urlencode "titles=$f" \
              -d "action=query&prop=imageinfo&iiprop=url&format=json" 2>/dev/null \
              | "$jq" -r '.query.pages[]?.imageinfo[]?.url // empty' 2>/dev/null | head -1)
            if [ -n "$u" ] && [ "$u" != "$2" ]; then echo "$u"; return 0; fi
          done
          echo ""
        }

        # DuckDuckGo image fallback (arg1=nth result, 1-based). Empty on miss.
        ddg_image() {
          vqd=$("$curl" -fsSL -A "$ua" --max-time 15 "https://duckduckgo.com/?q=$host" 2>/dev/null \
            | grep -oE 'vqd=[0-9-]+' | head -1 | cut -d= -f2)
          [ -z "$vqd" ] && return 0
          "$curl" -fsSL -A "$ua" --max-time 15 \
            "https://duckduckgo.com/i.js?l=us-en&o=json&q=$host&vqd=$vqd&f=,,,&p=1" 2>/dev/null \
            | "$jq" -r '.results[]?.image // empty' 2>/dev/null | sed -n "$1p"
        }

        want() { # mode -> target path, or empty if already satisfied
          m="$1"
          [ -f "$committed/$host-$m.jpg" ] && return 1
          [ -f "$base/$m/$host-$m.jpg" ] && return 1
          return 0
        }

        # dark slot: wikipedia lead (nl then en), else DDG #1
        if want dark; then
          url="$(wiki_lead nl)"; [ -z "$url" ] && url="$(wiki_lead en)"
          [ -z "$url" ] && url="$(ddg_image 1)"
          download "$url" "$base/dark/$host-dark.jpg" || true
        fi

        # light slot: a *different* wikipedia image, else DDG #2, else reuse dark
        if want light; then
          darkurl=""
          [ -f "$base/dark/$host-dark.jpg" ] && darkurl="have"
          url="$(wiki_other nl "")"; [ -z "$url" ] && url="$(wiki_other en "")"
          [ -z "$url" ] && url="$(ddg_image 2)"
          if ! download "$url" "$base/light/$host-light.jpg"; then
            # last resort: reuse the dark image so light mode still shows the host
            [ -f "$base/dark/$host-dark.jpg" ] && \
              ${pkgs.coreutils}/bin/cp "$base/dark/$host-dark.jpg" "$base/light/$host-light.jpg" || true
          fi
        fi

        exit 0
      '';
    in
    {
      options.mip.hostWallpaper.enable =
        lib.mkEnableOption "hostname-derived Hyprland wallpaper (first-run download of a dark + light image)";

      config = lib.mkIf config.mip.hostWallpaper.enable {
        home.packages = [ fetchScript ];

        # Best-effort first-run fetch. `|| true` guarantees a failed download
        # (offline, blocked, no result) never aborts `home-manager switch`; the
        # guard inside the script makes it a no-op once images exist, and it
        # self-retries on later switches while they are still missing.
        home.activation.hostWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${fetchScript}/bin/host-wallpaper-fetch || true
        '';
      };
    };
}
