{ inputs, self, ... }:

let
  hostname = "harry";
in

  {
  flake.homeConfigurations = {

    "pim@harry" = self.lib.makeHomeConf {
      inherit hostname;
      server = true;
      system = "aarch64-linux";
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-minimal
        role-pim-cli-full
      ];
    };
  };

  flake.nixosConfigurations = {

    harry = self.lib.makeNixos {
      inherit hostname;
      system = "aarch64-linux";
    };
  };

  flake.modules.nixos.harry = { config, pkgs, ... } : {
    system.stateVersion = "23.11";

    imports = with inputs.self.modules.nixos; [

      channel-default
      system-default
      role-nebula-node
      system-trusted-pim
      networking-nebula
    ];

    environment.systemPackages = with pkgs; [
      nfs-utils
      libraspberrypi
      raspberrypi-eeprom
    ];

    services.openssh.enable = true;

    # Trust pim so deploy-rs can push store paths built locally on cichorei
    # (e.g. under aarch64 emulation) that aren't signed by cache.nixos.org.
    nix.settings.trusted-users = [ "root" "pim" ];

    # NixOS's 55-nixos-aslr-entropy.conf sets vm.mmap_rnd_bits to the new
    # kernel's max (33). During a `switch` (no reboot) systemd-sysctl applies
    # that to the still-running old kernel, which rejects 33 and fails
    # activation. Pin to 18 (arm64 4K-page min, the upstream kernel default),
    # which is valid on both kernels. Lands in 60-nixos.conf, overriding 55-.
    # Safe to remove and let it return to 33 once harry runs the new kernel.
    #boot.kernel.sysctl."vm.mmap_rnd_bits" = 18;

  };

}
