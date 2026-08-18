{ ... }:
{
  # Reusable role: hourly restic backups to the piethein Synology NAS over SFTP
  # as the non-admin `resticbackup` user. Enable per host and list datasets;
  # each dataset becomes its own restic repository under /ResticBackups/<repo>.
  #
  #   mipnix.backup.piethein = {
  #     enable = true;
  #     datasets.cichorei-claude = {
  #       paths = [ "/home/pim/.claude" ];
  #       keep  = [ "--keep-hourly" "24" "--keep-daily" "7" ];
  #     };
  #   };
  flake.modules.nixos.backup-restic-piethein = { config, pkgs, lib, ... }:
    let
      cfg = config.mipnix.backup.piethein;
      host = "192.168.2.100";
      user = "resticbackup";

      datasetType = lib.types.submodule ({ name, ... }: {
        options = {
          repo = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Repository directory name under /ResticBackups.";
          };
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Paths to back up. For DB dumps, the dump file path produced by prepareCommand.";
          };
          keep = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            example = [ "--keep-hourly" "24" "--keep-daily" "7" ];
            description = "restic forget --keep-* retention arguments for this repo.";
          };
          prepareCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Shell run (as root) before the backup — e.g. a DB dump to a file.";
          };
          cleanupCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Shell run (as root) after the backup — e.g. remove the dump file.";
          };
        };
      });
    in
    {
      options.mipnix.backup.piethein = {
        enable = lib.mkEnableOption "hourly restic backups to the piethein Synology NAS";
        datasets = lib.mkOption {
          type = lib.types.attrsOf datasetType;
          default = { };
          description = ''
            Datasets to back up. Each becomes its own restic repository at
            sftp:resticbackup@piethein:/ResticBackups/<repo>, with its own
            retention policy.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        # Shared backup key (transport) + repo password (encryption). Both are
        # root-only; restic runs as root and reads them directly. Keep an OFFLINE
        # copy of both — a dead host cannot decrypt its own agenix secrets.
        age.secrets.restic-ssh-key.file = ../../../secrets/restic-ssh-key.age;
        age.secrets.restic-repo-pw.file = ../../../secrets/restic-repo-pw.age;

        # Pin piethein's host key so the unattended sftp connection can verify it
        # (systemd runs non-interactively and cannot accept-new).
        programs.ssh.knownHosts.piethein = {
          hostNames = [ host ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtMn0HX7dtu6pQJzpNqOnNhYBOQXP2YugVjJaCxVbj2";
        };

        services.restic.backups = lib.mapAttrs (name: ds:
          {
            repository = "sftp:${user}@${host}:/ResticBackups/${ds.repo}";
            passwordFile = config.age.secrets.restic-repo-pw.path;
            paths = ds.paths;
            initialize = true;
            # restic's sftp backend shells out to ssh; point it at the dedicated
            # key and pin the host key (StrictHostKeyChecking=yes uses the
            # /etc/ssh/ssh_known_hosts entry above).
            extraOptions = [
              "sftp.command=ssh -i ${config.age.secrets.restic-ssh-key.path} -o StrictHostKeyChecking=yes -o BatchMode=yes ${user}@${host} -s sftp"
            ];
            timerConfig = {
              OnCalendar = "hourly";
              Persistent = true; # catch up one missed run after downtime
              RandomizedDelaySec = "30m"; # stagger hosts so they don't all hit the NAS at once
            };
            pruneOpts = ds.keep;
          }
          // lib.optionalAttrs (ds.prepareCommand != null) { backupPrepareCommand = ds.prepareCommand; }
          // lib.optionalAttrs (ds.cleanupCommand != null) { backupCleanupCommand = ds.cleanupCommand; }
        ) cfg.datasets;
      };
    };
}
