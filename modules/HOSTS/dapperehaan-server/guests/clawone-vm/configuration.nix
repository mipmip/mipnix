{ inputs, self, ... }:

let
  hostname = "clawone";
in
{

  flake.modules.nixos.clawone = { config, pkgs, lib, ... }: {
    system.stateVersion = "25.11";

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
