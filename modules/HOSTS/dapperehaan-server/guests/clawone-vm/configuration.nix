{ inputs, self, ... }:

let
  hostname = "clawone";
in
{

  flake.modules.nixos.clawone = { config, pkgs, lib, ... }: {
    system.stateVersion = "25.11";

    imports = [
      inputs.agenix.nixosModules.default
      inputs.nix-openclaw.nixosModules.openclaw-gateway
    ];

    microvm = {
      hypervisor = "qemu";
      vcpu = 2;
      mem = 2049;

      interfaces = [{
        type = "tap";
        id = "vm-clawone";
        mac = "02:00:00:00:01:01";
      }];

      volumes = [{
        mountPoint = "/var";
        image = "clawone-var.img";
        size = 8192;
      }];

      shares = [{
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "virtiofs";
      }];
    };

    # Agenix secrets
    age.secrets.matrix-openclaw-password = {
      file = ../../../../../secrets/matrix-openclaw-password.age;
      owner = "openclaw";
      group = "openclaw";
      mode = "400";
    };

    # OpenClaw workspace documents
    environment.etc."openclaw/workspace/AGENTS.md".source = ./documents/AGENTS.md;
    environment.etc."openclaw/workspace/SOUL.md".source = ./documents/SOUL.md;
    environment.etc."openclaw/workspace/TOOLS.md".source = ./documents/TOOLS.md;

    # OpenClaw gateway
    services.openclaw-gateway = {
      enable = true;
      package = inputs.nix-openclaw.packages."${pkgs.stdenv.hostPlatform.system}".openclaw-gateway.overrideAttrs (old: {
        pnpmDeps = old.pnpmDeps.overrideAttrs { hash = "sha256-mFZKNKBtHr6/4j8auYRCnbyo7jBK/aJWbV9zuq/vPR4="; };
      });
      config = {
        gateway.mode = "local";
        defaults.model.primary = "openai/gpt-4.1";
        agents.defaults.workspace = "/etc/openclaw/workspace";
        channels.matrix = {
          homeserverUrl = "https://nuremberg.pimnsnel.com";
          userId = "@openclaw1:nuremberg.pimnsnel.com";
          passwordFile = config.age.secrets.matrix-openclaw-password.path;
          autoJoin = true;
        };
      };
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    security.sudo.wheelNeedsPassword = false;

    users.users.pim = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };

}
