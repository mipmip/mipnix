{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shellstuff-desktop = { pkgs, ... }:
    let
        ## dispatched open command. Non blocking and independant of starting terminal
        open = pkgs.writeShellScriptBin "open" ''
          xdg-open "''$@" & disown
        '';
    in
    {
      home.packages = [
        open
      ];
  };
}
