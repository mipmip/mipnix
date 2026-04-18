{ inputs, ... } : {
  flake.modules.nixos.system-trusted-annemarie = { config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      age
    ];

    age.secrets = let
      keyconf = keyname: {
        file = ../../../secrets/${keyname}.age;
        path = "/tmp/annemarie_${keyname}";
        owner = "annemarie";
        group = "users";
        mode = "600";
      };

      keyconf_root = keyname: {
        file = ../../../secrets/${keyname}.age;
        path = "/tmp/annemarie_${keyname}";
        owner = "root";
        group = "root";
        mode = "600";
      };
    in
      {

      kagi-api-key-plain = keyconf "kagi-api-key-plain";

      # including export for use with home manager
      bedrock-annemarie-api-keys-env = keyconf "bedrock-annemarie-api-keys-env";


    };

  };
}
