{ inputs, self, ... }:

let
  hostname = "dapperehaan";
in

  {

  flake.homeConfigurations = {

    "pim@dapperehaan" = self.lib.makeHomeConf {
      inherit hostname;
    };
  };

  flake.nixosConfigurations = {

    dapperehaan = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.dapperehaan = { config, pkgs, ... } : {
    system.stateVersion = "25.11";

    imports = with inputs.self.modules.nixos; [

      channel-default
      system-trusted-pim

      system-default
      role-server
      role-devbox
      system-trusted-pim
      services-samba
      role-nebula-node

      desktop-virt-virtualization # for distrobox

      inputs.microvm.nixosModules.host
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-cd79d237-a831-4ba0-a732-db23f6680a78".device =
      "/dev/disk/by-uuid/cd79d237-a831-4ba0-a732-db23f6680a78";
    networking.networkmanager.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "mac-iso";
    };

    # microvm host networking for clawone guest
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking.nat.enable = false;
    systemd.services.microvm-nat = {
      description = "NAT for microvm guests";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp0s10 -s 10.0.100.0/24 -j MASQUERADE";
        ExecStop = "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp0s10 -s 10.0.100.0/24 -j MASQUERADE";
      };
    };

    systemd.network.enable = true;
    systemd.network.networks."50-microvm-clawone" = {
      matchConfig.Name = "vm-clawone";
      addresses = [ { Address = "10.0.100.1/24"; } ];
      networkConfig.DHCPServer = false;
    };

    microvm.vms.clawone = {
      config = {
        imports = [ inputs.self.modules.nixos.clawone ];
      };
    };

  };

}
