{ inputs, self, ... }:

let
  hostname = "dapperehaan";

  # Single definition of this host's restic datasets; consumed both by the backup
  # role below and (as bare repo names) by the aggregated `flake.resticRepos`.
  #
  # One dataset, and it is the Work pool's authoritative copy. The laptops in the
  # pool never talk to piethein at all: they sync to this host over nebula, and
  # this host is the only NAS client. Long retention, because this is the data the
  # pool exists to not lose.
  datasets = {
    dapperehaan-work.paths = [ "/home/pim/Work" ];
    dapperehaan-work.keep = [
      "--keep-hourly" "24" "--keep-daily" "7" "--keep-weekly" "5"
      "--keep-monthly" "12" "--keep-yearly" "9999"
    ];
  };
in

  {

  # Syncthing Work pool membership. The ID is the hash of this host's
  # certificate in secrets/syncthing-dapperehaan.crt.age; the two travel together.
  flake.syncthingDevices.dapperehaan = "P7VV7FB-QH3QRPH-C4PQKJB-O7UDYRP-MW6QGNY-47N353N-57C6362-Q2DTDAZ";

  flake.resticRepos.dapperehaan = builtins.attrNames datasets;

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

    # Allow pim to push unsigned store paths (deploy-rs). Matches durer/hurry/harry.
    nix.settings.trusted-users = [ "root" "pim" ];

    imports = with inputs.self.modules.nixos; [

      channel-default
      system-trusted-pim

      system-default
      role-server
      role-devbox
      system-trusted-pim
      services-samba
      role-nebula-node

      syncthing-work-pool
      backup-restic-piethein

      #desktop-virt-virtualization # for distrobox

      #inputs.microvm.nixosModules.host
    ];

    # Hub of the Work pool: holds the authoritative copy of /home/pim/Work
    # receive-only, versions whatever arrives, and is the only member that backs
    # the folder up. See modules/services/sync/syncthing-pool.nix.
    mipnix.syncthing.pool = {
      enable = true;
      hub = true;
    };

    # Hourly restic of the pool folder to piethein. Direct over the LAN
    # (192.168.2.22 to 192.168.2.100), so no relay, unlike durer.
    mipnix.backup.piethein = {
      enable = true;
      inherit datasets;
    };

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.defaultSession = "gnome";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."luks-cd79d237-a831-4ba0-a732-db23f6680a78".device =
      "/dev/disk/by-uuid/cd79d237-a831-4ba0-a732-db23f6680a78";
    networking.networkmanager.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "mac-iso";
    };

  };

}
