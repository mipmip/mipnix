{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shellstuff = { pkgs, ... }:

    let

      ## smg is bound to bind + S in tmux and shows all preconfigured smus tmux sessions
      smg = pkgs.writeShellScriptBin "smg" ''
        profile=$(${pkgs.smug}/bin/smug list | ${pkgs.gum}/bin/gum filter)

        if [ -z "''$profile" ] || [ "''$profile" -eq "" ]
        then
          echo "smg cancelled"
          exit 0
        fi

        dir=$(grep "root:" ~/.config/smug/''$profile.yml | head -1 | cut -d " " -f2)
        if [ -z "''$dir" ] || [ "''$dir" -eq "" ]
        then
          echo "no root defined"
          exit 0
        else
          eval dir="''$dir"
          mkdir -v -p "''$dir"
        fi
        ${pkgs.smug}/bin/smug start "''$profile"
        ${pkgs.tmux}/bin/tmux switch -t "''$profile"
        '';

      ## detrun
      o = pkgs.writeShellScriptBin "o" ''
        setsid xdg-open "$@" < /dev/null > /dev/null 2>&1
        '';


    in
    {
      home.packages = [
        smg
        o
        #inputs.shellstuff.packages."${pkgs.system}".shellstuff
      ];
  };
}
