{ self, lib, inputs, ... } : {

  flake.homeConfigurations = {
    "annemarie@passieflora" = self.lib.makeHomeConf {
      hostname = "passieflora";
      desktop = true;
      username = "annemarie";
      homedir = "/home/annemarie";
    };

    "annemarie@lavendel" = self.lib.makeHomeConf {
      hostname = "lavendel";
    };
  };

  flake.modules.nixos.user-annemarie = { config, pkgs, ... }: {
    users.users.annemarie = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "disk"];
    };
  };

  flake.modules.homeManager.annemarie = {

    programs.hm-ricing-mode.enable = true;

    imports = with inputs.self.modules.homeManager; [
      annemarie-myhotkeys
    ];
  };
}
