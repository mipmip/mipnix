{ ... }:
{
  # Nautilus (GNOME Files) right-click script: Scripts ▸ Copy Path.
  #
  # Copies the selected item(s)' absolute path(s) to the Wayland clipboard. This is a
  # Nautilus *script* (an executable Nautilus runs with $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
  # set), NOT a nautilus-python extension — so it uses no Nautilus API and survives
  # GNOME/Nautilus upgrades. wl-copy is referenced by Nix store path, so it works
  # without wl-clipboard being in systemPackages and without a PATH dependency.
  #
  # Nautilus uses the filename as the menu label, hence "Copy Path".
  flake.modules.homeManager.pim-nautilus-copy-path = { pkgs, ... }: {
    home.file.".local/share/nautilus/scripts/Copy Path" = {
      executable = true;
      text = ''
        #!/bin/sh
        # $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS: absolute paths, one per line, with a
        # trailing newline. --trim-newline drops that trailing newline so a single
        # selection pastes as a bare path.
        printf '%s' "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" \
          | ${pkgs.wl-clipboard}/bin/wl-copy --trim-newline
      '';
    };
  };
}
