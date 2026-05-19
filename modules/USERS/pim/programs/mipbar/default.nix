{
inputs,
...
}:
{
  flake.modules.homeManager.pim-mipbar = { pkgs, ... }: {

    home.packages = [
      inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".mipbar
      pkgs.brightnessctl
    ];

    programs.hm-ricing-mode.apps.mipbar = {
      dest_dir = ".config/mipbar";
      source_dir = "$HOME/mipnix/packages/mipbar";
      type = "symlink";
    };

  };
}
