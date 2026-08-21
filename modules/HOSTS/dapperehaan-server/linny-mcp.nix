{ inputs, ... }:
{
  flake.modules.nixos.dapperehaan = { config, pkgs, ... }:
  let
    corpus = "/var/lib/secondbrain";
    stateDir = "/var/lib/linny-mcp/personal";
    deployKey = config.age.secrets."secondbrain-deploy-key".path;
    # ssh via the read/write deploy key only; known_hosts kept outside the repo
    # working tree (in the module StateDirectory) so git-sync never tries to sync it.
    sshCmd = "${pkgs.openssh}/bin/ssh -i ${deployKey} -o IdentitiesOnly=yes "
      + "-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/var/lib/linny-mcp/known_hosts";
  in
  {
    imports = [ inputs.linny-mcp.nixosModules.linny-mcp ];

    # Bring the linny-mcp package into pkgs for the module's default package.
    nixpkgs.overlays = [ inputs.linny-mcp.overlays.default ];

    # Bearer-token records (hashed) + the read/write deploy key for git-sync.
    # Owned by the service user; never a token/key literal in a Nix option.
    age.secrets."linny-mcp-tokens" = {
      file = ../../../secrets/linny-mcp-tokens.age;
      owner = "linny-mcp";
      group = "linny-mcp";
      mode = "400";
    };
    age.secrets."secondbrain-deploy-key" = {
      file = ../../../secrets/secondbrain-deploy-key.age;
      owner = "linny-mcp";
      group = "linny-mcp";
      mode = "400";
    };

    services.linny-mcp = {
      enable = true;
      # Bind the nebula mesh IP (RFC1918 -> accepted by the binary, no override).
      # TLS terminates upstream on durer; never a public bind.
      listenAddress = "192.168.100.2";
      port = 8765;
      publicHostname = "secondbrain.pimsnel.com";
      # Corpus MUST live outside /home: the unit sets ProtectHome = true.
      corpusPath = corpus;
      stateDir = stateDir;
      tokensFile = config.age.secrets."linny-mcp-tokens".path;
      quarantine = true;   # keep agent-created docs quarantined (default)
      readOnly = false;    # writable brain
      # ntfyTopicURL deferred -> .beans/mipnix-2dyz
    };

    # Corpus + state dirs owned by the service user. The stateDir subdir must
    # exist before start: the hardened unit's ReadWritePaths bind-mounts it, so a
    # missing path fails namespace setup (226/NAMESPACE) before exec.
    systemd.tmpfiles.rules = [
      "d ${corpus} 0750 linny-mcp linny-mcp - -"
      "d /var/lib/linny-mcp 0750 linny-mcp linny-mcp - -"
      "d ${stateDir} 0750 linny-mcp linny-mcp - -"
    ];

    # One-time clone bootstrap: git-sync assumes an existing repo.
    systemd.services.secondbrain-clone = {
      description = "bootstrap clone of mipmip/secondbrain for linny-mcp";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [ "linny-mcp.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.GIT_SSH_COMMAND = sshCmd;
      path = [ pkgs.git pkgs.openssh ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "linny-mcp";
        Group = "linny-mcp";
      };
      script = ''
        if [ ! -e ${corpus}/.git ]; then
          git clone git@github.com:mipmip/secondbrain ${corpus}
        fi
      '';
    };

    # Bidirectional sync (GitHub as hub) via git-sync, as the linny-mcp user.
    systemd.services.git-sync-secondbrain = {
      description = "bidirectional git-sync of the secondbrain corpus";
      after = [ "secondbrain-clone.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      requires = [ "secondbrain-clone.service" ];
      environment.GIT_SSH_COMMAND = sshCmd;
      path = [ pkgs.git pkgs.git-sync pkgs.openssh ];
      serviceConfig = {
        Type = "oneshot";
        User = "linny-mcp";
        Group = "linny-mcp";
        WorkingDirectory = corpus;
      };
      script = ''
        b=$(git symbolic-ref --short HEAD)
        git config user.name  "linny-mcp"
        git config user.email "linny-mcp@dapperehaan"
        # git-sync refuses a branch not explicitly opted in; enable + allow new files
        # (agent writes are untracked until synced).
        git config --bool branch."$b".sync true
        git config --bool branch."$b".syncNewFiles true
        exec git-sync -n
      '';
    };

    systemd.timers.git-sync-secondbrain = {
      description = "run git-sync of the secondbrain corpus every 30s";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "30s";
        Unit = "git-sync-secondbrain.service";
      };
    };
  };
}
