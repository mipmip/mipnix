{
inputs,
...
}:
{
  flake.modules.homeManager.pim-hyprland = { pkgs, lib, ... }:
    let
      # binds.conf is generated from the hotkey registry (binds.nix beside this
      # file), so a Hyprland key is declared once and reaches the compositor,
      # the myhotkeys sheet and the keyb sheet from that one declaration.
      #
      # Only the bindings are generated. $mainMod belongs to this file because
      # nothing else defines it, and the commented-out examples below are kept
      # verbatim: they are notes about bindings that are not in force, which the
      # registry has nothing to say about.
      bindsConf = pkgs.writeText "hypr-binds.conf" ''
        ###################
        ### KEYBINDINGS ###
        ###################

        # See https://wiki.hypr.land/Configuring/Keywords/
        #
        # GENERATED from modules/USERS/pim/programs/hyprland/binds.nix.
        # Edit the registry, not this file.

        $mainMod = SUPER # Sets "Windows" key as main modifier

        ${inputs.self.lib.hotkeys.toHyprland inputs.self.hotkeys}

        # Example special workspace (scratchpad)
        #bind = $mainMod, S, togglespecialworkspace, magic
        #bind = $mainMod SHIFT, S, movetoworkspace, special:magic

        #bindm = Control_L SHIFT, left, movewindow
        #bindm = Control_L SHIFT, right, movewindow

        ## Noctalia Shell IPC keybindings
        #bind = $mainMod, A, exec, noctalia-shell ipc launcher
        #bind = $mainMod SHIFT, E, exec, noctalia-shell ipc session-menu
        #bind = $mainMod, V, exec, noctalia-shell ipc volume

        ## Requires playerctl
        #bindl = , XF86AudioNext, exec, playerctl next
        #bindl = , XF86AudioPause, exec, playerctl play-pause
        #bindl = , XF86AudioPlay, exec, playerctl play-pause
        #bindl = , XF86AudioPrev, exec, playerctl previous
      '';
    in
    {

    # Reload Hyprland after home-manager links new config files, so monitor/
    # keybind/etc. changes apply deterministically on `home-manager switch`.
    # Without this, Hyprland's own file-watcher can fire mid-swap and read stale
    # config (e.g. leaving a monitor at its fallback `auto` position). Runs after
    # onFilesChange (files already linked); no-op when Hyprland isn't running.
    home.activation.reloadHyprland = lib.hm.dag.entryAfter [ "onFilesChange" ] ''
      if ${pkgs.procps}/bin/pgrep -x Hyprland > /dev/null 2>&1; then
        run ${pkgs.hyprland}/bin/hyprctl reload > /dev/null 2>&1 || true
      fi
    '';

    #wayland.windowManager.hyprland.systemd.enable = false;

    #    wayland.windowManager.hyprland.enable = true;
    #    wayland.windowManager.hyprland.plugins = [
    #      unstable-hyprland.hyprlandPlugins.hyprbars
    #      #unstable-hyprland.hyprlandPlugins.hyprexpo
    #    ];

    home.file = {
      ".config/hypr" = {
        source = ./hypr;
        recursive = true;
      };
      ".config/hypr/scripts" = {
        source = ./scripts;
        recursive = true;
      };
      ".config/hypr/binds.conf".source = bindsConf;
    };

    programs.hm-ricing-mode.apps.hypr = {
      dest_dir = ".config/hypr";
      source_dir = "$HOME/nixos/home/pim/_hm-modules/programs/hyprland/hypr";
      type = "symlink";
    };

    # ashell config removed — replaced by mipbar

    # Walker + Elephant from official nixpkgs/home-manager (golden path).
    # Walker via the home-manager services.walker module (package defaults to
    # pkgs.walker); Elephant as the pkgs.elephant package with default config.
    # Custom Elephant providers/settings were dropped — see openspec change
    # walker-elephant-from-nixpkgs; re-add declaratively if missed.
    #
    # systemd.enable = false on purpose: the systemd user service is WantedBy
    # graphical-session.target, which this Hyprland session does NOT populate
    # (no uwsm/systemd integration), so the service would never auto-start.
    # Walker is launched via `exec-once` in autostart.conf instead.
    services.walker = {
      enable = true;
      systemd.enable = false;
    };

    # hyprpolkitagent: a polkit authentication agent for the Hyprland session.
    # Without a running agent, polkit-mediated auth prompts have nowhere to
    # appear — which is why Bitwarden greys out "Unlock with system
    # authentication" (its biometric/system-auth unlock goes through polkit).
    #
    # The package installs only a libexec binary (no bin/) plus a systemd user
    # unit. Starting it via the unit makes the Qt6 agent crash (SIGABRT) under
    # the unit's restricted environment; launched directly from the Hyprland
    # session it runs fine. So expose a small PATH wrapper and exec-once it from
    # autostart.conf (this session doesn't populate graphical-session.target
    # anyway, so the unit wouldn't auto-start — same reason Walker uses
    # exec-once). The wrapper keeps the nix-store path out of the static conf.
    home.packages = [
      pkgs.elephant
      (pkgs.writeShellScriptBin "hyprpolkitagent-start"
        "exec ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent")
    ];

    home.file = {
      ".config/wpaperd" = {
        source = ./wpaperd;
        recursive = true;
      };
    };

  };
}
