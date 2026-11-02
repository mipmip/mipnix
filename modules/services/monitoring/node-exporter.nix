{ inputs, ... }:
{
  flake.modules.nixos.monitoring-node-exporter = { config, lib, pkgs, ... }:
    let
      host = config.networking.hostName;
      registry = inputs.self.nebulaNodes;
      port = 9100;
      textDir = "/var/lib/prometheus-node-exporter-text";

      writeAtomically = name: ''
        tmp="$(mktemp -p ${textDir} .${name}.XXXXXX)"
        trap 'rm -f "$tmp"' EXIT
        collect > "$tmp"
        chmod 0644 "$tmp"
        mv "$tmp" ${textDir}/${name}
        trap - EXIT
      '';

      nixosMetrics = pkgs.writeShellScript "nixos-metrics" ''
        set -eu
        export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.findutils pkgs.gawk pkgs.jq config.nix.package ]}

        collect() {
          info="$(/run/current-system/sw/bin/nixos-version --json)"
          revision="$(jq -r '.configurationRevision // "unknown"' <<< "$info")"
          version="$(jq -r '.nixosVersion // "unknown"' <<< "$info")"
          nixpkgs="$(jq -r '.nixpkgsRevision // "unknown"' <<< "$info")"

          reboot=0
          for f in kernel initrd kernel-modules; do
            if [ "$(readlink -f /run/booted-system/$f)" != "$(readlink -f /run/current-system/$f)" ]; then
              reboot=1
            fi
          done

          echo "# HELP nixos_system_info NixOS revision, version and nixpkgs of the current system."
          echo "# TYPE nixos_system_info gauge"
          echo "nixos_system_info{revision=\"$revision\",version=\"$version\",nixpkgs=\"$nixpkgs\"} 1"
          echo "# TYPE nixos_system_switch_timestamp_seconds gauge"
          echo "nixos_system_switch_timestamp_seconds $(stat -c %Y /nix/var/nix/profiles/system)"
          echo "# TYPE nixos_reboot_required gauge"
          echo "nixos_reboot_required $reboot"
          echo "# TYPE nixos_system_generations gauge"
          echo "nixos_system_generations $(find /nix/var/nix/profiles -maxdepth 1 -name 'system-*-link' | wc -l)"
          echo "# TYPE nixos_home_manager_generations gauge"
          for profiles in /home/*/.local/state/nix/profiles; do
            [ -d "$profiles" ] || continue
            user="$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$profiles")")")")")"
            echo "nixos_home_manager_generations{user=\"$user\"} $(find "$profiles" -maxdepth 1 -name 'home-manager-*-link' | wc -l)"
          done
          echo "# TYPE nixos_system_closure_bytes gauge"
          echo "nixos_system_closure_bytes $(nix path-info -S /run/current-system | awk '{print $2}')"
        }

        ${writeAtomically "nixos.prom"}
      '';

      storeMetrics = pkgs.writeShellScript "nix-store-metrics" ''
        set -eu
        export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.findutils pkgs.gawk ]}

        collect() {
          echo "# TYPE nix_store_size_bytes gauge"
          echo "nix_store_size_bytes $(du -sb /nix/store | awk '{print $1}')"
          echo "# TYPE nix_store_paths gauge"
          echo "nix_store_paths $(find /nix/store -mindepth 1 -maxdepth 1 ! -name '.*' | wc -l)"
        }

        ${writeAtomically "nix-store.prom"}
      '';
    in
    lib.mkIf (registry ? ${host}) {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = registry.${host};
        inherit port;
        enabledCollectors = [ "systemd" "textfile" ];
        extraFlags = [
          "--collector.systemd.unit-include=(restic-backups-.*|hip-repo-backup|syncthing|nix-gc)\\.(service|timer)"
          "--collector.textfile.directory=${textDir}"
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

      systemd.tmpfiles.rules = [ "d ${textDir} 0755 root root -" ];

      systemd.services.nixos-metrics = {
        description = "Write NixOS facts for node-exporter";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = nixosMetrics;
        };
      };
      systemd.timers.nixos-metrics = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "1h";
        };
      };

      systemd.services.nix-store-metrics = {
        description = "Write Nix store size for node-exporter";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = storeMetrics;
          Nice = 19;
          IOSchedulingClass = "idle";
        };
      };
      systemd.timers.nix-store-metrics = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "2h";
        };
      };

      networking.firewall.interfaces."nebula.mesh".allowedTCPPorts = [ port ];
    };
}
