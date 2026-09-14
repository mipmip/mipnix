{ inputs, ... } : {
  flake.modules.nixos.dev-infra-iac = { config, pkgs, ... }:
    let
      # Global `terraform` binary that transparently forwards to tofu.
      # Lives in PATH so it works in every shell (not a shell alias).
      terraform = pkgs.writeShellScriptBin "terraform" ''
        exec ${pkgs.opentofu}/bin/tofu "''$@"
      '';

      # The nivis-tunnel package publishes `bin/tunnel`, but upstream's README
      # documents every invocation as `nivis-tunnel connect`, `nivis-tunnel
      # keygen`, and so on. Rename it here so a command copied from the README
      # works verbatim, and so a name as generic as `tunnel` does not claim a
      # slot in the system PATH. Same shape as the terraform wrapper above.
      # If upstream ever ships the binary under its documented name, drop this.
      nivis-tunnel = pkgs.writeShellScriptBin "nivis-tunnel" ''
        exec ${inputs.nivis-tunnel.packages."${pkgs.stdenv.hostPlatform.system}".tunnel}/bin/tunnel "''$@"
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

      # Orchestrator side only. The agent belongs on a target and has its own
      # NixOS module upstream; the relay is durer's job (networking-nivis-tunnel-relay).
      nivis-tunnel
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
