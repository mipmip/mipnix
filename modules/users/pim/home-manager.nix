{ inputs, self, ... }:
{
  flake.homeConfigurations = {

    "pim@passieflora" = self.lib.makeHomeConf {
      hostname = "passieflora";
      desktop = true;
    };

    "pim@hurry" = self.lib.makeHomeConf {
      hostname = "hurry";
      system = "aarch64-linux";
    };

    "pim@harry" = self.lib.makeHomeConf {
      hostname = "harry";
      system = "aarch64-linux";
    };

    "pim@arcana-one" = self.lib.makeHomeConf {
      hostname = "arcana-one";
    };
  };
}

