{ inputs, ... } : {
  flake.modules.nixos.dev-infra-iac = { config, pkgs, ... }:
    let
      # Global `terraform` binary that transparently forwards to tofu.
      # Lives in PATH so it works in every shell (not a shell alias).
      terraform = pkgs.writeShellScriptBin "terraform" ''
        exec ${pkgs.opentofu}/bin/tofu "''$@"
      '';
    in
    {
    environment.systemPackages = with pkgs; [

      terraform


      # DIAGRAM
      #    drawio
      graphviz

      # OFFICE365
      #onedrivegui
      #onedrive

      # 2FA
      authenticator

      sqlite

      # PASSWORDS
      gnupg
      pass


      attic-client


      # AWS
      cw # cloudwatch in the terminal
      aws-mfa
      awsweeper

      pkgs.unstable.awscli2
      ssm-session-manager-plugin
      aws-vault
      ssmsh

      #git-remote-codecommit

      #azure-cli

      # TERRAFORM
      terraform-docs
      opentofu

      # nivis: Terraform/OpenTofu provider resources as first-class Nix values.
      # `inputs` comes from this file's outer function argument, the same way
      # tui/tmux.nix reaches inputs.skull. Do NOT add `inputs` to the inner
      # module args to get at it — that shadows the outer binding (the mistake
      # desktop/apps/markdown.nix makes).
      inputs.nivis.packages."${pkgs.stdenv.hostPlatform.system}".nivis
      terrascan
      terraformer
      tflint

      #terraform

      notify # Notify allows sending the output from any tool to Slack, Discord and Telegram
      ssl-cert-check

      vulnix


    ];

  };
}
