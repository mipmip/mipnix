{ inputs, ... } : {

  flake.modules.nixos.vibecoding-main = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.unstable.rtk
      pkgs.unstable.beans

      #inputs.openspec.packages."${pkgs.stdenv.hostPlatform.system}".default

      ## util programs used by agents
      tree

      ## notification support for claude-code
      libnotify  # provides notify-send
    ];
  };


  flake.modules.nixos.vibecoding-utils = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mods
    ];
  };
}

