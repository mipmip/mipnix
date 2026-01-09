{ inputs, ... } : {
  flake.modules.nixos.system-trusted-agenix = { config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      age
    ];

    age.secrets = let
      keyconf = keyname: {
        file = ../../../secrets/${keyname}.age;
        path = "/tmp/${keyname}";
        owner = "pim";
        group = "users";
        mode = "600";
      };

      keyconf_root = keyname: {
        file = ../../../secrets/${keyname}.age;
        path = "/tmp/${keyname}";
        owner = "root";
        group = "root";
        mode = "600";
      };
    in
      {

      open-api-key = keyconf "openai-api-key";
      openai-api-key-plain = keyconf "openai-api-key-plain";
      kagi-api-key-plain = keyconf "kagi-api-key-plain";
      tavily-api-key-plain = keyconf "tavily-api-key-plain";

      # including export for use with home manager
      bedrockpim-api-keys-env = keyconf "bedrockpim-api-keys-env";
      bedrock-keys-for-avante-env = keyconf "bedrock-keys-for-avante-env";

      # for use this with litellm
      env-for-litellm = keyconf "env-for-litellm";


      id_ed25519_remotebuild = keyconf_root "id_ed25519_remotebuild";
    };

  };
}
