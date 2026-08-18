{ ... }:
{
  # Reusable role: hourly restic backups to the piethein Synology NAS over SFTP
  # as the non-admin `resticbackup` user. Enable per host and list datasets;
  # each dataset becomes its own restic repository under /ResticBackups/<repo>.
  #
  # LAN hosts (cichorei, hurry) reach piethein directly. durer is a cloud host
  # with no route to piethein's LAN address, so it tunnels through a relay Pi
  # over nebula (proxyJump, with failover). A relay host sets `relay = true`.
  flake.modules.nixos.backup-restic-piethein = { config, pkgs, lib, ... }:
    let
      cfg = config.mipnix.backup.piethein;
      host = "192.168.2.100";
      user = "resticbackup";
      relayUser = "restic-relay";
      keyPath = config.age.secrets.restic-ssh-key.path;

      # Public half of the dedicated backup key (also on piethein's authorized_keys).
      backupPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm37zpE3yhSOt6aNMtTHo4zpzUo/sm+gSc8yuW5lCwE restic-backup@mipnix";

      # ProxyCommand script: try each relay in order (fast-fail on connect),
      # forwarding a TCP channel to piethein:22. Kept as a script file so the
      # sftp.command value stays a single space-free token (no quote nesting).
      proxyScript = pkgs.writeShellScript "restic-piethein-proxy"
        (lib.concatMapStringsSep " || " (j:
          ''${pkgs.openssh}/bin/ssh -i ${keyPath} -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -W ${host}:22 ${relayUser}@${j}''
        ) cfg.proxyJump);

      sftpBase = "ssh -i ${keyPath} -o StrictHostKeyChecking=yes -o BatchMode=yes";
      sftpCommand =
        if cfg.proxyJump == [ ]
        then "${sftpBase} ${user}@${host} -s sftp"
        else "${sftpBase} -o ProxyCommand=${proxyScript} ${user}@${host} -s sftp";

      datasetType = lib.types.submodule ({ name, ... }: {
        options = {
          repo = lib.mkOption { type = lib.types.str; default = name; description = "Repository dir under /ResticBackups."; };
          paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; description = "Paths to back up (or the dump file for DB targets)."; };
          keep = lib.mkOption { type = lib.types.listOf lib.types.str; example = [ "--keep-hourly" "24" ]; description = "restic forget --keep-* args."; };
          prepareCommand = lib.mkOption { type = lib.types.nullOr lib.types.lines; default = null; description = "Run (as root) before backup — e.g. a DB dump."; };
          cleanupCommand = lib.mkOption { type = lib.types.nullOr lib.types.lines; default = null; description = "Run (as root) after backup — e.g. remove the dump."; };
        };
      });
    in
    {
      options.mipnix.backup.piethein = {
        enable = lib.mkEnableOption "hourly restic backups to the piethein Synology NAS";
        relay = lib.mkEnableOption "act as a nebula→LAN relay so cloud hosts can reach piethein through this host";
        proxyJump = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "192.168.100.6" "192.168.100.7" ];
          description = "Relay hosts (nebula IPs) to tunnel through, tried in order for failover. Empty = connect directly.";
        };
        datasets = lib.mkOption {
          type = lib.types.attrsOf datasetType;
          default = { };
          description = "Datasets to back up; each becomes its own restic repo under /ResticBackups.";
        };
      };

      config = lib.mkIf cfg.enable (lib.mkMerge [
        # Backup side — only for hosts that actually back up (have datasets).
        # Relay-only hosts (e.g. harry) skip this and never touch the private
        # key secret, so they don't need to be agenix recipients.
        (lib.mkIf (cfg.datasets != { }) {
          age.secrets.restic-ssh-key.file = ../../../secrets/restic-ssh-key.age;
          age.secrets.restic-repo-pw.file = ../../../secrets/restic-repo-pw.age;

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
              # Single-quoted: the restic module splices this into a shell line
              # unquoted, so an unquoted value would word-split.
              extraOptions = [ "sftp.command='${sftpCommand}'" ];
              timerConfig = {
                OnCalendar = "hourly";
                Persistent = true;
                RandomizedDelaySec = "30m";
              };
              pruneOpts = ds.keep;
            }
            // lib.optionalAttrs (ds.prepareCommand != null) { backupPrepareCommand = ds.prepareCommand; }
            // lib.optionalAttrs (ds.cleanupCommand != null) { backupCleanupCommand = ds.cleanupCommand; }
          ) cfg.datasets;
        })

        # Relay: a locked-down user whose only capability is forwarding a TCP
        # channel to piethein:22 (no shell, no pty, no other forwards).
        (lib.mkIf cfg.relay {
          users.groups.${relayUser} = { };
          users.users.${relayUser} = {
            isSystemUser = true;
            group = relayUser;
            shell = "${pkgs.util-linux}/bin/nologin";
            openssh.authorizedKeys.keys = [
              ''restrict,port-forwarding,permitopen="${host}:22" ${backupPubKey}''
            ];
          };
        })
      ]);
    };
}
