{ inputs, ... } : {
  flake.modules.nixos.networking-nebula = { pkgs, lib, config, ... }:
  let
    cfg = config.mipnix.nebula;
  in {

    options.mipnix.nebula = {
      lighthouses = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = { "192.168.100.1" = "lighthouse.example.com:4242"; };
        description = ''
          Registry of nebula lighthouses: nebula VPN IP -> underlay endpoint
          ("host:port"). Single source of truth for the mesh's lighthouse set;
          every node derives its lighthouse list and static host map from this.
        '';
      };

      isLighthouse = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether this host acts as a nebula lighthouse. A lighthouse advertises
          an empty lighthouse-hosts list; a normal node lists every lighthouse.
        '';
      };
    };

    config = {

      # Every node's /etc/hosts entry derived from the single-source registry
      # (flake.nebulaNodes), so the mesh is name-resolvable and no IP literal is
      # restated per host. Reads only literal strings from the flake output, so it
      # does not force nixosConfigurations (no inputs.self recursion).
      networking.extraHosts = lib.concatStrings (
        lib.mapAttrsToList (name: ip: "${ip} ${name}\n") inputs.self.nebulaNodes
      );

      age = {
        secrets = {
          "nebula-ca-cert" = {
            file = ../../../secrets/nebula-ca.crt.age;
            path = "/var/lib/nebula/nebula-ca.crt";
            owner = "nebula-mesh";
            group = "root";
            mode = "600";
          };
          "nebula-sshd-hostkey" = {
            file = ../../../secrets/nebula-sshd-hostkey.age;
            path = "/var/lib/nebula/nebula-sshd-hostkey.crt";
            owner = "nebula-mesh";
            group = "root";
            mode = "600";
          };
        };
      };

      # Single source of truth for the mesh's lighthouses.
      mipnix.nebula.lighthouses = {
        # technative (currently unreachable after a network refactor; kept listed
        # so nodes rejoin it automatically once it is reachable again).
        "192.168.100.1" = "vaultwarden.tools.technative.cloud:4242";
        # durer @ Hetzner (stable public IPv4 behind nuremberg.pimsnel.com).
        "192.168.100.12" = "nuremberg.pimsnel.com:4242";
      };

      services.nebula.networks.mesh = {
        enable = true;

        # Derived from mipnix.nebula.* — see options above.
        isLighthouse = cfg.isLighthouse;
        # A lighthouse must advertise an empty lighthouse-hosts list; a normal
        # node reports to every lighthouse in the registry.
        lighthouses = if cfg.isLighthouse then [ ] else builtins.attrNames cfg.lighthouses;

        settings = {
          cipher = "aes";

          sshd = {
            enabled = true;
            listen = "127.0.0.1:2222";
            host_key = config.age.secrets.nebula-sshd-hostkey.path;
            authorized_users = [
              {
                user = "pim";
                keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh";
              }
            ];
          };
        };

        ca = config.age.secrets.nebula-ca-cert.path;

        # Every node maps every lighthouse. A lighthouse retaining its own entry
        # here is inert (a node never dials itself via the static host map).
        staticHostMap = builtins.mapAttrs (ip: ep: [ ep ]) cfg.lighthouses;

        firewall.outbound = [
          {
            host = "any";
            port = "any";
            proto = "any";
          }
        ];
        firewall.inbound = [
          {
            host = "any";
            port = "any";
            proto = "any";
          }
        ];
      };

    };

  };
}
