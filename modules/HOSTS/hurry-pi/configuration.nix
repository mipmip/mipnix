{ inputs, self, ... }:

let
  hostname = "hurry";

  # Single definition of this host's restic datasets; consumed both by the backup
  # role below and (as bare repo names) by the aggregated `flake.resticRepos`.
  datasets = {
    hurry-vaultwarden.paths = [ "/var/lib/backups/vaultwarden" ];
    hurry-vaultwarden.keep = [ "--keep-hourly" "24" "--keep-daily" "14" "--keep-monthly" "6" ];

    hurry-ssh.paths = [ "/home/pim/.ssh" ];
    hurry-ssh.keep = [ "--keep-hourly" "24" "--keep-daily" "7" ];
  };
in



  {

  flake.resticRepos.hurry = builtins.attrNames datasets;

  flake.homeConfigurations = {
    "pim@hurry" = self.lib.makeHomeConf {
      inherit hostname;
      system = "aarch64-linux";
      server = true;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-minimal
        role-pim-cli-full
      ];

    };
  };

  flake.nixosConfigurations = {
    hurry = self.lib.makeNixos {
      inherit hostname;
      system = "aarch64-linux";
    };
  };

  flake.modules.nixos.hurry = { config, pkgs, ... } : {
    system.stateVersion = "23.11";

    imports = with inputs.self.modules.nixos; [

      channel-default

      system-default

      role-nebula-node

      system-trusted-pim

      backup-restic-piethein

    ];

    # Hourly restic backups to piethein. vaultwarden's backupDir is already a
    # consistent sqlite snapshot; keep 2 weeks daily + 6 months.
    mipnix.backup.piethein = {
      enable = true;
      relay = true; # bridge durer (nebula) → piethein (LAN)
      inherit datasets;
    };

    # Additional packages for server
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];

    # Enable SSH
    services.openssh.enable = true;

    # Trust pim so deploy-rs can push store paths built locally on cichorei
    # (e.g. under aarch64 emulation) that aren't signed by cache.nixos.org.
    nix.settings.trusted-users = [ "root" "pim" ];

    # NixOS's 55-nixos-aslr-entropy.conf sets vm.mmap_rnd_bits to the new
    # kernel's max (33). During a `switch` (no reboot) systemd-sysctl applies
    # that to the still-running old kernel, which rejects 33 and fails
    # activation. Pin to 18 (arm64 4K-page min, the upstream kernel default),
    # which is valid on both kernels. Lands in 60-nixos.conf, overriding 55-.
    # Safe to remove and let it return to 33 once hurry runs the new kernel.
    boot.kernel.sysctl."vm.mmap_rnd_bits" = 18;

  };

}
