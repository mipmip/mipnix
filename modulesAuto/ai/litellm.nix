{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.nixos.litellm;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      litellm
    ];

    services.litellm = {
      package = unstable.litellm;
      enable = true;
      environmentFile = "/tmp/env-for-litellm";

      settings = {
        model_list = [
          {
            model_name = "bedrock-claude-3-5-sonnet";
            litellm_params = {
              model = "bedrock/anthropic.claude-3-5-sonnet-20240620-v1:0";
              aws_region_name = "eu-central-1";
            };
          }

          {
            model_name = "claude-sonnet-4-5";
            litellm_params = {
              model = "bedrock/eu.anthropic.claude-sonnet-4-5-20250929-v1:0";
              aws_region_name = "eu-central-1";
            };
          }
        ];
      };
    };

    # Create the environment file template
    # You'll need to create /run/secrets/litellm-env with:
    # AWS_BEARER_TOKEN_BEDROCK=your_token_here
    # AWS_REGION=us-east-1
    # LITELLM_MASTER_KEY=your_master_key_here (optional)
  };
}

