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
    #
    # MUST be a single space-free token: backrest word-splits each `flags` entry
    # before exec, so an inline "ssh -i key …" would leak "-i" as a top-level
    # restic flag ("unknown shorthand flag: 'i'"). Same reason restic-piethein.nix
    # ships its proxy as a script. So wrap the ssh invocation in a store script.
    sftpWrapper = pkgs.writeShellScript "backrest-piethein-sftp" ''
      exec ${pkgs.openssh}/bin/ssh -i ${keyPath} \
        -o StrictHostKeyChecking=yes -o BatchMode=yes \
        ${nasUser}@${nasHost} -s sftp "$@"
    '';

    # Every piethein repo, derived from the aggregated flake.resticRepos registry.
    # The repo password is supplied to restic via RESTIC_PASSWORD_FILE (path only —
    # the value never enters the config file); SFTP auth uses the shared key.
    repoNames = lib.concatLists (lib.attrValues self.resticRepos);
    mkRepo = name: {
      id = name;
      uri = "sftp:${nasUser}@${nasHost}:/ResticBackups/${name}";
      env = [ "RESTIC_PASSWORD_FILE=${repoPwPath}" ];
      flags = [ "-o" "sftp.command=${sftpWrapper}" ];
      # Backrest's config validation requires each repo to carry either a 64-char
      # guid or autoInitialize. These repos already exist (backups run), so
      # autoInitialize just lets backrest connect and derive the guid on first use;
      # it only ever *creates* a repo that is genuinely not found.
      autoInitialize = true;
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

    # Seed the generated config into the writable state dir, re-seeding whenever the
    # Nix-generated template changes (tracked by a stamp of its store path). Between
    # deploys with an unchanged template, backrest owns config.json (its runtime
    # writes — filled repo GUIDs, identity — persist). A template change (new repo,
    # changed flags) overwrites; backrest simply re-derives the runtime bits.
    # Injects the base64(bcrypt(...)) login hash from the agenix secret so it never
    # lands in the world-readable store.
    stampPath = "${stateDir}/.seed-template";
    seedScript = pkgs.writeShellScript "backrest-seed-config" ''
      set -eu
      if [ ! -f ${configPath} ] || [ "$(cat ${stampPath} 2>/dev/null || true)" != "${configTemplate}" ]; then
        ${pkgs.jq}/bin/jq --arg h "$(cat ${authPath})" \
          '.auth.users[0].passwordBcrypt = $h' ${configTemplate} > ${configPath}
        chmod 600 ${configPath}
        printf '%s' "${configTemplate}" > ${stampPath}
      fi
    '';

    # backrest binds the nebula IP directly, but on `ListenAndServe` failure it
    # LOGS and exits 0 (backrest.go:151) — a clean exit systemd won't retry under
    # Restart=on-failure. So wait for the mesh IP to be assigned before starting
    # (avoids the bind race), and pair with Restart=always as a backstop.
    waitScript = pkgs.writeShellScript "backrest-wait-nebula" ''
      set -eu
      for i in $(seq 1 60); do
        if ${pkgs.iproute2}/bin/ip -4 addr show | grep -q '192\.168\.100\.2'; then
          exit 0
        fi
        sleep 1
      done
      echo "nebula mesh IP 192.168.100.2 not up after 60s" >&2
      exit 1
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
      # backrest can exit 0 on a failed bind, so never rate-limit restarts.
      startLimitIntervalSec = 0;
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
        ExecStartPre = [ waitScript seedScript ];
        ExecStart = "${pkgs.backrest}/bin/backrest";
        Restart = "always";
        RestartSec = 5;

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
