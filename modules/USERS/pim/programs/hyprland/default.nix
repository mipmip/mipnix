{
inputs,
...
}:
{
  flake.modules.homeManager.pim-hyprland = { pkgs, ... }: {

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

    home.packages = [ pkgs.elephant ];

    home.file = {
      ".config/wpaperd" = {
        source = ./wpaperd;
        recursive = true;
      };
    };

  };
}
