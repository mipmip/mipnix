{
...
}:
{
  flake.modules.nixos.stinkie = { config, ... }: {

    # The PSK as an agenix path, never a literal: anything written into a Nix
    # option lands in the world-readable store. envsubst substitutes $JAPI_PSK
    # into the generated keyfiles at activation, and the unit runs with
    # UMask=0177 so what it writes is 0600.
    age.secrets.wifi-japi-psk = {
      file = ../../../secrets/wifi-japi-psk.age;
      owner = "root";
      group = "root";
      mode = "400";
    };

    # Two profiles for one SSID, one per radio, ordered by priority.
    #
    # stinkie has a 1x1 Intel AC 3168 on PCIe and a 2x2 TP-Link Archer T4U v2
    # (RTL8812AU) on USB 3. Measured against the same AP on channel 36:
    #
    #   wlp3s0       -54 dBm   rx 433.3  tx 390.0   VHT-NSS 1
    #   wlp0s20f0u4  -46 dBm   rx 526.6  tx 866.7   VHT-NSS 2
    #
    # So the USB adapter is primary and the internal card is the fallback that
    # NetworkManager brings up on its own if the T4U cannot associate.
    #
    # Bonding the two was considered and rejected: 802.3ad needs a switch as
    # link partner, and balance-* modes need the AP to accept frames from a MAC
    # that is not the associated station. Both radios would also contend for the
    # same airtime on the same channel. active-backup is the only workable
    # bonding mode over wifi and buys nothing that autoconnect-priority does not.
    #
    # UUIDs are pinned to the ones already on the machine so these replace the
    # hand-made profiles rather than duplicating them.
    networking.networkmanager.ensureProfiles = {
      environmentFiles = [ config.age.secrets.wifi-japi-psk.path ];

      profiles = {
        japi-t4u = {
          connection = {
            id = "japi-t4u";
            uuid = "ad9e2844-a216-47d4-89ab-83c25d4a316a";
            type = "wifi";
            interface-name = "wlp0s20f0u4";
            autoconnect = true;
            autoconnect-priority = 10;
          };
          wifi = {
            ssid = "japi";
            mode = "infrastructure";
            # 5 GHz only. If that band is unreachable this profile simply fails
            # to associate and the internal card takes over on 2.4.
            band = "a";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$JAPI_PSK";
          };
          ipv4 = {
            method = "auto";
            route-metric = 100;
          };
          ipv6 = {
            method = "auto";
            route-metric = 100;
            addr-gen-mode = "stable-privacy";
          };
        };

        japi = {
          connection = {
            id = "japi";
            uuid = "97e1e261-3e74-4aab-b8e0-4f3f06bc7fe7";
            type = "wifi";
            interface-name = "wlp3s0";
            autoconnect = true;
            autoconnect-priority = 5;
          };
          wifi = {
            ssid = "japi";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$JAPI_PSK";
          };
          ipv4 = {
            method = "auto";
            route-metric = 600;
          };
          ipv6 = {
            method = "auto";
            route-metric = 600;
            addr-gen-mode = "stable-privacy";
          };
        };
      };
    };

  };
}
