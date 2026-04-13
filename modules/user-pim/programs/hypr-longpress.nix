{
...
}:
{
  flake.modules.homeManager.pim-hypr-longpress = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellScriptBin "hypr-longpress" ''
        export PATH="${pkgs.rofi}/bin:$PATH"
        exec ${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3 \
          ${./hyprland/scripts/hypr-longpress} "$@"
      '')
    ];
  };
}
