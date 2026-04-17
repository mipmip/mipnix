{
  inputs,
  ...
}:
{
  flake.modules.nixos.role-desktop-pim = {
    imports = with inputs.self.modules.nixos; [
      # Desktop foundation - System
      desktop-system-x11
      desktop-system-security
      desktop-system-services

      # Desktop foundation - Hardware
      desktop-hw-audio
      desktop-hw-video
      desktop-hw-keyboard
      desktop-myhotkeys

      # Desktop foundation - Utils
      desktop-utils-fonts

      # Desktop environments
      desktop-de-gnome
      #desktop-de-kde
      #desktop-de-elementary
      desktop-de-hyprland

      # Desktop applications
      desktop-apps-browsers
      desktop-apps-mail
      desktop-apps-communication
      desktop-apps-news
      desktop-apps-ai
      desktop-apps-dtp
      desktop-apps-markdown
      desktop-apps-dev

      # Desktop tools & hardware
      desktop-virt-virtualization
      desktop-virt-appimage
      desktop-hw-bambu-labs
      desktop-hw-printers
      desktop-utils-filesync

      virtualisation-waydroid

    ];
  };
}

