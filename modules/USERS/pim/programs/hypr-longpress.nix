{
...
}:
{
  flake.modules.homeManager.pim-hypr-longpress = { pkgs, ... }: {
    home.packages = [
      (pkgs.writeShellScriptBin "hypr-longpress" ''
        export PATH="${pkgs.rofi}/bin:${pkgs.libinput}/bin:$PATH"
        exec ${pkgs.python3}/bin/python3 \
          ${./hyprland/scripts/hypr-longpress} "$@"
      '')
    ];
  };
}
