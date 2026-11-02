{ config, ... }:
let
  registryJson = config.flake.lobby.json;
in
{
  perSystem = { pkgs, ... }:
    let
      json = pkgs.writeText "lobby.json" registryJson;
      plex = "${pkgs.ibm-plex}/share/fonts/truetype";
    in
    {
      packages.lobby-web = pkgs.runCommand "lobby-web" { } ''
        mkdir -p $out/fonts
        cp ${json} $out/lobby.json
        substitute ${../../packages/lobby/index.template.html} $out/index.html \
          --replace-fail '@REGISTRY_JSON@' "$(cat ${json})"
        for f in IBMPlexMono-Regular IBMPlexMono-SemiBold IBMPlexSans-Regular IBMPlexSans-Medium IBMPlexSans-SemiBold; do
          cp ${plex}/$f.ttf $out/fonts/
        done
      '';

      packages.lobby = pkgs.writeShellApplication {
        name = "lobby";
        runtimeInputs = [ pkgs.jq pkgs.gawk pkgs.coreutils pkgs.gnugrep pkgs.gum pkgs.xdg-utils ];
        text = builtins.replaceStrings [ "@LOBBY_JSON@" ] [ "${json}" ]
          (builtins.readFile ../../packages/lobby/lobby.sh);
      };
    };
}
