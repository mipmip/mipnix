{ inputs, self, ... }:
{
  # Backrest — a nebula-only web console to browse and restore restic snapshots
  # across every piethein repository. Modelled on linny-mcp.nix (nebula-bound
  # service on dapperehaan). dapperehaan shares piethein's LAN (192.168.2.22 ↔
  # 192.168.2.100), so SFTP is direct — no relay, unlike durer.
  #
  # Viewer/restore only: repos are registered with NO backup plans, so it never
  # schedules backups that would collide with the NixOS restic timers.
  flake.modules.nixos.dapperehaan = { config, pkgs, lib, ... }:
  let
    user = "backrest";
    stateDir = "/var/lib/backrest";
    configPath = "${stateDir}/config.json";
    dataDir = "${stateDir}/data";

    nasUser = "resticbackup";
    nasHost = "192.168.2.100";
    keyPath = config.age.secrets.restic-ssh-key.path;
    repoPwPath = config.age.secrets.restic-repo-pw.path;
    authPath = config.age.secrets.backrest-auth.path;

    # restic SFTP command — direct on the LAN, no ProxyCommand. Host key is pinned
    # via programs.ssh.knownHosts.piethein below, so StrictHostKeyChecking=yes.
    sftpCommand = "${pkgs.openssh}/bin/ssh -i ${keyPath} "
      + "-o StrictHostKeyChecking=yes -o BatchMode=yes ${nasUser}@${nasHost} -s sftp";

    # Every piethein repo, derived from the aggregated flake.resticRepos registry.
    # The repo password is supplied to restic via RESTIC_PASSWORD_FILE (path only —
    # the value never enters the config file); SFTP auth uses the shared key.
    repoNames = lib.concatLists (lib.attrValues self.resticRepos);
    mkRepo = name: {
      id = name;
      uri = "sftp:${nasUser}@${nasHost}:/ResticBackups/${name}";
      env = [ "RESTIC_PASSWORD_FILE=${repoPwPath}" ];
      flags = [ "-o" "sftp.command=${sftpCommand}" ];
    };

    # version 6 == CurrentVersion for backrest 1.14.1 (a fresh v6 config skips all
    # migrations; repo GUIDs are filled lazily on first connect). The auth hash is a
    # placeholder; the seed step injects the real secret so it never lands in the
    # world-readable store.
    configTemplate = pkgs.writeText "backrest-config.json" (builtins.toJSON {
      version = 6;
      instance = "dapperehaan";
      repos = map mkRepo repoNames;
      plans = [ ];
      auth = {
        disabled = false;
        users = [ { name = "pim"; passwordBcrypt = "@BACKREST_AUTH@"; } ];
      };
    });

    # Seed the generated config into the writable state dir on first start only;
    # backrest owns config.json thereafter (it rewrites + chmods it). Injects the
    # base64(bcrypt(...)) login hash from the agenix secret.
    seedScript = pkgs.writeShellScript "backrest-seed-config" ''
      set -eu
      if [ ! -f ${configPath} ]; then
        ${pkgs.jq}/bin/jq --arg h "$(cat ${authPath})" \
          '.auth.users[0].passwordBcrypt = $h' ${configTemplate} > ${configPath}
        chmod 600 ${configPath}
      fi
    '';
  in
  {
    age.secrets = {
      restic-ssh-key = {
        file = ../../../secrets/restic-ssh-key.age;
        owner = user;
        group = user;
        mode = "400";
      };
      restic-repo-pw = {
        file = ../../../secrets/restic-repo-pw.age;
        owner = user;
        group = user;
        mode = "400";
      };
      backrest-auth = {
        file = ../../../secrets/backrest-auth.age;
        owner = user;
        group = user;
        mode = "400";
      };
    };

    # Pin piethein's host key so the direct-LAN SFTP verifies (value from
    # restic-piethein.nix). Written to /etc/ssh/ssh_known_hosts for system ssh.
    programs.ssh.knownHosts.piethein = {
      hostNames = [ nasHost ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtMn0HX7dtu6pQJzpNqOnNhYBOQXP2YugVjJaCxVbj2";
    };

    users.groups.${user} = { };
    users.users.${user} = {
      isSystemUser = true;
      group = user;
      home = stateDir;
    };

    systemd.services.backrest = {
      description = "Backrest — restic browse/restore console (nebula-only)";
      after = [ "network-online.target" "nebula@mesh.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BACKREST_CONFIG = configPath;
        BACKREST_DATA = dataDir;
        # Bind the nebula mesh IP only; default would be 127.0.0.1:9898.
        BACKREST_PORT = "192.168.100.2:9898";
        # Pin restic so backrest never downloads its own binary.
        BACKREST_RESTIC_COMMAND = "${pkgs.restic}/bin/restic";
        HOME = stateDir;
      };
      serviceConfig = {
        User = user;
        Group = user;
        StateDirectory = "backrest";
        StateDirectoryMode = "0700";
        ExecStartPre = seedScript;
        ExecStart = "${pkgs.backrest}/bin/backrest";
        Restart = "on-failure";
        RestartSec = 10;

        # Hardening. Restores land under the state dir; widen ReadWritePaths if a
        # different restore target is needed.
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ReadWritePaths = [ stateDir ];
      };
    };
  };
}
