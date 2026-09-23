{
inputs,
...
}:
{
  flake.modules.homeManager.pim-beandex = { pkgs, ... }: {
    home.packages = [
      inputs.beandex.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];

    # beandex refuses to run without a config file, so manage it declaratively.
    # Single scan path: ~ at depth 2, matching pim's repo layout
    # (~/<short>.<owner>/<repo>, per the huphop clone pattern).
    xdg.configFile."beandex/config.yaml".text = ''
      scan_paths:
        - path: "~"
          max_depth: 2
    '';
  };
}
