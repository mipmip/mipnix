{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.nixos.litellm;

  # Override litellm to include database and proxy dependencies
  litellmPython = pkgs.python313Packages.litellm.overridePythonAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or [])
      ++ (old.optional-dependencies.proxy or [])
      ++ (old.optional-dependencies.extra_proxy or []);
  });

  prismaPyth = (pkgs.python313.withPackages (python-pkgs: with python-pkgs; [
    prisma
  ]));


  litellmWithDb = unstable.litellm.override {
    python3Packages = unstable.python313Packages // {
      litellm = litellmPython;
    };
  };
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      #litellm
      #python313Packages.prisma
      #prisma
    ];


    systemd.services.litellm = {
      path = [pkgs.nodejs pkgs.python313Packages.prisma pkgs.bash];
      environment = {
        HOME = "/tmp";
        #PRISMA_NODEENV_CACHE_DIR = "/tmp/.cache";
        #PRISMA_USE_NODEJS_BIN = "False";
        PRISMA_NODEENV_CACHE_DIR = pkgs.nodejs;
        PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
        PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
        PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      };
      serviceConfig = {

        ExecStartPre = pkgs.writeShellScript "builder.sh" ''
          echo TRYING
          ${lib.getExe prismaPyth} -m prisma generate --schema ${pkgs.litellm}/lib/python3.13/site-packages/litellm/proxy/schema.prisma;
          '';

          #${lib.getExe prismaPyth} -m prisma generate --schema /tmp/.cache/schema.prisma;
          #${pkgs.coreutils-full}/bin/cp ${pkgs.litellm}/lib/python3.13/site-packages/litellm/proxy/schema.prisma /tmp/.cache
        #ExecStartPre =
        #ExecStartPre = "cp ${pkgs.litellm}/lib/python3.13/site-packages/litellm/proxy/schema.prisma /tmp/.cache &&
        #${lib.getExe prismaPyth} -m prisma generate --schema ${pkgs.litellm}/lib/python3.13/site-packages/litellm/proxy/schema.prisma";
        #ExecStartPre = "${lib.getExe pkgs.prisma} generate --schema ${pkgs.litellm}/lib/python3.13/site-packages/litellm/proxy/schema.prisma";
      };
    };

    services.litellm = {
      #package = litellmWithDb;
      enable = false;
      environmentFile = "/tmp/env-for-litellm";

      settings = {

        environment_variables = {
          #PORT=4000 # DO THIS FOR RENDER/RAILWAY
          STORE_MODEL_IN_DB="True"; # Allow storing models in db
        };

        model_list = [
          {
            model_name = "bedrock-claude-3-5-sonnet";
            litellm_params = {
              model = "bedrock/anthropic.claude-3-5-sonnet-20240620-v1:0";
              aws_region_name = "eu-central-1";
            };
          }

          {
            model_name = "bedrock-claude-sonnet-4-5";
            litellm_params = {
              model = "bedrock/eu.anthropic.claude-sonnet-4-5-20250929-v1:0";
              aws_region_name = "eu-central-1";
            };
          }
        ];
      };
    };
  };
}

