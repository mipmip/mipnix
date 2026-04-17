{
...
}:
{
  flake.modules.homeManager.pim-with-secondbrain = { lib, config, ... }: {

    homeWith.secondbrain.enable = true;
    home.file = {
      "${config.home.homeDirectory}/.i-am-second-brain" = {
        text = '''';
      };

    };
  };
}
