{ inputs, ... } : {
  flake.modules.nixos.hardware-keychron = { pkgs, unstable, ... }: {

    # KEYCHRON KEYBOARD SWAP FN KEY
    boot.extraModprobeConfig = ''
        options hid_apple fnmode=2
    '';

    boot.kernelModules = [ "hid-apple"  ];

    boot.kernelParams = [ "hid_apple.fnmode=2" ];

  };
}





