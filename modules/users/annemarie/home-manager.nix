{ inputs, self, ... }:
{
  flake.homeConfigurations = {

    "annemarie@passieflora" = self.lib.makeHomeConf {
      hostname = "passieflora";
      desktop = true;
      username = "annemarie";
      homedir = "/home/annemarie";
    };
  };
}
