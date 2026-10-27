{ inputs, self, ... }:

let
  hostname = "stinkie";
in

{

  flake.syncthingDevices.stinkie = "CDLHB62-QND3KF7-MEZ2A4Y-LRTQ7U4-GC4EHT3-42UO34M-ASYR7ZP-33326QP";

  flake.homeConfigurations = {

    # CLI only: stinkie is a server now, so role-pim-desktop (firefox,
    # thunderbird, hyprland, gimp, obs, mipbar, wallpaper) is gone along with
    # the NixOS desktop role.
    "pim@stinkie" = self.lib.makeHomeConf {
      inherit hostname;
      imports = with inputs.self.modules.homeManager; [
        role-pim-cli-full
        role-pim-cli-minimal
      ];
    };
  };

  flake.nixosConfigurations = {

    stinkie = self.lib.makeNixos {
      inherit hostname;
      system = "x86_64-linux";
    };
  };

  flake.modules.nixos.stinkie = { config, pkgs, lib, ... } : {
    system.stateVersion = "26.05";

    # Allow pim to push unsigned store paths (deploy-rs). Matches
    # dapperehaan/durer/hurry/harry. Without it `rme deploy_remote stinkie`
    # fails at the copy step with "lacks a signature by a trusted key".
    nix.settings.trusted-users = [ "root" "pim" ];

    imports = with inputs.self.modules.nixos; [

      system-default
      channel-default

      role-devbox
      role-server
      role-nebula-node

      system-trusted-pim
      secrets-honeybadger
      nix-github-token
      syncthing-work-pool

    ];

    mipnix.syncthing.pool.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # The GTX 1050 driver survives the desktop removal for NVENC transcoding,
    # and for CUDA once a card and an onnxruntime that can use it are in place.
    # videoDrivers is what gates the whole nvidia module in nixpkgs, not
    # services.xserver.enable, so listing it here with X switched off is the
    # supported headless form.
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      # OFF deliberately: it kills the text console on this machine.
      #
      # modesetting exists so NVIDIA can drive displays. With it on, nixpkgs
      # sets nvidia-drm.modeset=1 and (driver >= 545) nvidia-drm.fbdev=1, and
      # nvidia-drm claims the console when it loads ~100s into boot. It then
      # declines to provide a framebuffer, because every connector on the card
      # reports "disconnected" (a detection quirk; the monitor is attached, but
      # DVI-D without hotplug-detect, or a KVM, reads as absent):
      #
      #   Console: switching to colour frame buffer device 100x37   <- simpledrm
      #   [drm] Initialized nvidia-drm ... on minor 1
      #   Console: switching to colour dummy device 80x25           <- console lost
      #
      # The screen then keeps showing whatever simpledrm drew last, frozen, with
      # no cursor and no echo, while getty is still running behind it.
      #
      # stinkie is headless and needs the console only for the LUKS passphrase
      # and emergencies, so leaving the firmware framebuffer in charge is
      # strictly better. CUDA and NVENC do not need KMS.
      modesetting.enable = false;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      powerManagement.enable = false;
    };

    console.keyMap = "nl";

    boot.initrd.systemd.contents."/etc/vconsole.conf".source =
      lib.mkForce (pkgs.writeText "vconsole.conf" "KEYMAP=us\n");

    users.users."pim" = {
      isNormalUser = true;
      description = "pim";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      vim
      gum
      tmux
      git
      htop
      btop
      claude-code
    ];

    services.openssh.enable = true;

  };

}
