{ inputs, ... } : {
  flake.modules.nixos.desktop-de-hyprland = { config, pkgs, ... }: {

    programs = {
      dconf.enable = true;
      xwayland.enable = true;

      # The screen locker for this session. `enable` is what installs
      # security.pam.services.hyprlock. NixOS ships default PAM stacks for
      # swaylock/i3lock/vlock/xlock but NOT for hyprlock, so without this the
      # locker falls through to /etc/pam.d/other, which is pam_warn + pam_deny
      # and therefore rejects every password by construction. It also installs
      # the package, so hyprlock is not listed in systemPackages below.
      hyprlock.enable = true;

      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        #plugins = [
        #  inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        #];

      };
    };

    security.polkit.enable = true;

    # The machine must never put itself to sleep; sleeping is a deliberate act
    # (lid close, the suspend keybind, an explicit systemctl suspend). This
    # matches the systemd default, so it changes nothing today. It is declared
    # so the property belongs to this repo rather than to an upstream default,
    # and so it is discoverable next to the lock policy it belongs with.
    # Idle LOCKING is a separate concern, owned by hypridle (see hypridle.conf).
    services.logind.settings.Login.IdleAction = "ignore";

    # SVG support in GTK apps. This Hyprland session is launched by GDM and does
    # NOT run a full GNOME/KDE session, so nothing sets GDK_PIXBUF_MODULE_FILE
    # session-wide. Without it, GdkPixbuf falls back to the default loaders
    # cache, which lacks the SVG loader (librsvg is a separate package), so SVGs
    # fail to render everywhere. This module builds a combined loaders.cache and
    # sets GDK_PIXBUF_MODULE_FILE via environment.sessionVariables (/etc/set-
    # environment), which the GDM session — and thus every GTK app launched from
    # Hyprland — inherits.
    #services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

    #services.displayManager.sessionPackages = [ pkgs.upstream-hyprland.hyprland ];

    # Portal backend routing for this Hyprland session. xdg.portal.enable and the
    # gtk/hyprland backends are configured elsewhere; here we only fix routing.
    #
    # Under XDG_CURRENT_DESKTOP=Hyprland the Settings interface
    # (org.freedesktop.impl.portal.Settings — color-scheme, accent, fonts) was
    # routing to the hyprland backend, which does NOT implement it. The gtk
    # backend implements Settings but its .portal file is tagged UseIn=gnome, so
    # under Hyprland nothing served the request → GDK logged
    # "Failed to read portal settings: AccessDenied ... /proc/<pid>/root".
    # Explicitly send Settings to gtk; keep hyprland first for everything else
    # (ScreenCast/Screenshot) with gtk as the general fallback.
    xdg.portal.config.Hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };

    #    services.input-remapper = {
    #      enable = true;
    #    };

    # Hint Electron apps to use wayland.
    #
    # NIXOS_OZONE_WL is the switch the NixOS Electron/Chromium wrappers check to
    # inject their Wayland flags — including
    # `--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer`, which
    # is required for PipeWire screen capture through the desktop portal.
    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    # Screen sharing fix for portal-mediated ScreenCast (Slack, and any
    # Electron/Chromium app on Wayland).
    #
    # With the Wayland flags above, Slack DOES call org.freedesktop.portal.
    # ScreenCast, but the portal frontend then failed to authorize the request:
    #   Failed to request session: org.freedesktop.DBus.Error.AccessDenied:
    #   Portal operation not allowed: Unable to open /proc/<pid>/root
    # To identify the calling app, the portal opens /proc/<caller-pid>/root — a
    # magic symlink gated by PTRACE_MODE_READ. Under the systemd/NixOS default
    # `kernel.yama.ptrace_scope = 1`, a same-user process that is NOT an ancestor
    # of the caller (the portal is not Slack's parent) is denied, so the
    # ScreenCast session is refused and Slack shows "give screen share access".
    #
    # Setting ptrace_scope = 0 lets the portal read the caller's /proc entry.
    # Trade-off: this permits any same-user process to ptrace another same-user
    # process (intra-user only; no cross-user or root impact) — the standard,
    # desktop-typical setting for portal-based screen capture.
    boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

    environment.systemPackages = with pkgs; [

      pamixer

      #hyprland
      hyprshot

      # Screenshot annotation, reached from the Bewerken button on the capture
      # notification (see hypr/scripts/shot-annotate). Its behaviour lives in
      # satty/config.toml rather than in flags on the command line.
      satty
      hyprnome
      hyprcursor
      hyprmon
      hyprviz
      rose-pine-hyprcursor

      # nwg-displays removed: it saves by writing ~/.config/hypr/monitors.conf,
      # which Home Manager installs as a read-only /nix/store symlink, so every
      # save failed. Monitor geometry is declared in hypr/monitors.conf and
      # rebuilt; runtime resolution changes live in mipbar's Displays menu.
      swaynotificationcenter
      wpaperd

      libinput
      wl-clipboard

      # Required by the workspace-monitor-rehome script (reads Hyprland socket2).
      socat

      #ashell  # replaced by mipbar

      # Idle daemon. Owns the idle timers AND the sleep transition: it holds a
      # logind sleep inhibitor, which is what lets the session lock BEFORE the
      # machine goes down rather than after it comes back. Replaces swayidle,
      # which was only ever wired here for idle timeouts.
      #
      # Deliberately NOT services.hypridle.enable: that module's user unit is
      # WantedBy graphical-session.target, which this session never populates
      # (no uwsm/systemd integration), so the unit would never start while
      # looking managed. Started from autostart.conf instead, the same way and
      # for the same reason as Walker and hyprpolkitagent.
      hypridle

      cliphist

      wofi
      awww

      #xdg-desktop-portal-gtk
      #xdg-desktop-portal-hyprland
      #xwayland
      #hyprshell
    ];

  };
}
