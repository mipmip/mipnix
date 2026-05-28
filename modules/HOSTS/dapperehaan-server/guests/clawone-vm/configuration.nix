{ inputs, self, ... }:

let
  hostname = "clawone";
in
{

  flake.modules.nixos.clawone = { config, pkgs, lib, ... }: {
    system.stateVersion = "25.11";

    imports = [
      inputs.agenix.nixosModules.default
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

    # OpenClaw workspace documents
    environment.etc."openclaw/workspace/AGENTS.md".source = ./documents/AGENTS.md;
    environment.etc."openclaw/workspace/SOUL.md".source = ./documents/SOUL.md;
    environment.etc."openclaw/workspace/TOOLS.md".source = ./documents/TOOLS.md;

    # System user for openclaw
    users.users.openclaw = {
      isSystemUser = true;
      group = "openclaw";
      home = "/var/lib/openclaw";
      createHome = true;
      shell = pkgs.bashInteractive;
    };
    users.groups.openclaw = {};

    # Install openclaw via npm on first boot, then run gateway
    environment.systemPackages = with pkgs; [ nodejs_22 bash git ];

    systemd.services.openclaw-install = {
      description = "Install OpenClaw via npm";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "openclaw";
        Group = "openclaw";
        WorkingDirectory = "/var/lib/openclaw";
        Environment = [
          "HOME=/var/lib/openclaw"
          "PATH=${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
          "npm_config_prefix=/var/lib/openclaw/.npm-global"
        ];
        ExecStart = "${pkgs.bash}/bin/bash -c 'test -x /var/lib/openclaw/.npm-global/bin/openclaw || ${pkgs.nodejs_22}/bin/npm install -g openclaw'";
      };
    };

    systemd.services.openclaw-gateway = {
      description = "OpenClaw gateway";
      after = [ "network-online.target" "openclaw-install.service" ];
      wants = [ "network-online.target" ];
      requires = [ "openclaw-install.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "openclaw";
        Group = "openclaw";
        WorkingDirectory = "/var/lib/openclaw";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "HOME=/var/lib/openclaw"
          "OPENCLAW_CONFIG_PATH=/var/lib/openclaw/openclaw.json"
          "OPENCLAW_STATE_DIR=/var/lib/openclaw"
          "PATH=/var/lib/openclaw/.npm-global/bin:${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
        ];
        ExecStart = "/var/lib/openclaw/.npm-global/bin/openclaw gateway --port 18789";
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
