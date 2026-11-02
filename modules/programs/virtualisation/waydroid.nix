{ ... }: {
  flake.modules.nixos.virtualisation-waydroid = { config, lib, ... }:
    let
      cfg = config.mipnix.virtualisation;
    in
    {
      options.mipnix.virtualisation.waydroid = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Run Android applications in a container. Set to false on a host that
          has no use for them; the runtime image costs around 0.7 GB of store.
        '';
      };

      config.virtualisation.waydroid.enable = cfg.waydroid;
    };
}
