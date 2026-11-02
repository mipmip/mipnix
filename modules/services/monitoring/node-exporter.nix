{ inputs, ... }:
{
  flake.modules.nixos.monitoring-node-exporter = { config, lib, ... }:
    let
      host = config.networking.hostName;
      registry = inputs.self.nebulaNodes;
      port = 9100;
    in
    lib.mkIf (registry ? ${host}) {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = registry.${host};
        inherit port;
        enabledCollectors = [ "systemd" ];
        extraFlags = [
          "--collector.systemd.unit-include=(restic-backups-.*|hip-repo-backup|syncthing)\\.(service|timer)"
        ];
      };

      systemd.services.prometheus-node-exporter = {
        after = [ "nebula@mesh.service" ];
        startLimitIntervalSec = 0;
        serviceConfig = {
          Restart = lib.mkForce "always";
          RestartSec = 5;
        };
      };

      networking.firewall.interfaces."nebula.mesh".allowedTCPPorts = [ port ];
    };
}
