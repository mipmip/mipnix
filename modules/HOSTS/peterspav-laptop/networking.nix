{
...
}:
let
  hostname = "peterspav";
in
{
  flake.nebulaNodes.peterspav = "192.168.100.16";

  flake.modules.nixos.peterspav = { config, pkgs, ... } : {

    networking.hostName = hostname;
    networking.firewall.enable = false;

    # The RTL8852AE (rtw89) stalls silently after a while: the link stays
    # associated, IPv4 dies at the next DHCP renewal, IPv6 RS fails with
    # ENOBUFS, and only a reconnect resets it. Power saving off alone did not
    # fix it, so also disable ASPM L1 and L1SS on the PCIe link.
    networking.networkmanager.wifi.powersave = false;
    boot.extraModprobeConfig = ''
      options rtw89_core disable_ps_mode=Y
      options rtw89_pci disable_aspm_l1=Y disable_aspm_l1ss=Y
    '';

  };
}
