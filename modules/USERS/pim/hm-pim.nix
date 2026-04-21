{ inputs, self, ... }:
{

  flake.modules.homeManager.pim = {
    imports = with inputs.self.modules.homeManager; [
    ];
  };

}

