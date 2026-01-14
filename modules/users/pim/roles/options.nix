{
...
}:
{
  flake.modules.homeManager.pim-homeWith-options = { lib, config, ... }: {

    options.homeWith.secondbrain = {
      enable = lib.mkEnableOption "Make secondbrain available on this computer";
    };

    options.homeWith.desktop = {
      enable = lib.mkEnableOption "Configure as desktop computer";
    };


  };
}
