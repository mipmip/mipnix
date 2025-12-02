{ config, lib, unstable,pkgs, ... }:{

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      unstable.firefox
      librewolf
      #ungoogled-chromium
    ];

    #  environment.sessionVariables = {
    #    MOZ_ENABLE_WAYLAND = "1";
    #  };

  };
}
