{ config, lib, pkgs, unstable, pkgs-2211,  ... }:{

  config = lib.mkIf config.nixos.dev.enable {
    environment.systemPackages = with pkgs; [

      # DIAGRAM
      #    drawio
      graphviz

      # OFFICE365
      #onedrivegui
      #onedrive

      # SHELL
      gum

      # 2FA
      authenticator

      sqlite

      # PASSWORDS
      gnupg
      pass

      #    unstable.nickel
      #    dhall

      attic-client

      #    unstable.dbgate

      # AWS
      cw # cloudwatch in the terminal
      aws-mfa
      awsweeper

      unstable.awscli2
      ssm-session-manager-plugin
      aws-vault
      ssmsh

      #git-remote-codecommit

      #azure-cli

      # TERRAFORM
      terraform-docs
      terrascan
      terraformer
      tflint

      pkgs-2211.terraform
      notify # Notify allows sending the output from any tool to Slack, Discord and Telegram
      ssl-cert-check

      vulnix


    ];

  };
}

