{
inputs,
...
}:
{
  flake.modules.homeManager.pim-shared-shell-aliases = { lib, config, ... }:
    let
          cfg = config.roles.secondbrain;
    in

      {
      options.roles.secondbrain = {
        enable = lib.mkEnableOption "Make secondbrain available on this computer";
      };

      config =
        lib.mkIf cfg.enable {
          home.file = {
            "${config.home.homeDirectory}/.i-am-second-brain" = {
              text = '''';
            };

          };
        };
    };
}
