{
inputs,
...
}:
{
  flake.modules.homeManager.pim-git = { pkgs, ... }: {
    home.packages = [
      inputs.dirty-repo-scanner.packages."${pkgs.stdenv.hostPlatform.system}".dirty-repo-scanner
    ];

    home.file = {
      "./.config/dirty-repo-scanner/config.yml" = {
        source = ./config.yml;
      };
    };
  };
}
