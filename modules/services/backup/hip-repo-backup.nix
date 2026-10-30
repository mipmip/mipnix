{ inputs, ... }:
{
  flake.modules.nixos.hip-repo-backup = { config, pkgs, lib, ... }:
    let
      user = "hip-backup";
      stateDir = "/var/lib/${user}";

      hip = inputs.hip.packages.${pkgs.stdenv.hostPlatform.system}.default;

      hipConfig = (pkgs.formats.yaml { }).generate "hip-backup-config.yaml" {
        base_dir = "${stateDir}/repos";
        clone_pattern_tpl = "{{.BaseDir}}/{{.Short}}.{{.OwnerLower}}/{{.Repo}}";
        clone_vcs = "git";
        providers = [
          {
            name = "github";
            type = "github";
            short = "gh";
            username = "mipmip";
            web_url = "https://github.com";
            clone_protocol = "https";
            auth.env = "HIP_GITHUB_TOKEN";
            all_owners = true;
            exclude_owners = [ "nix-community" ];
            include_archived = true;
            include_forks = false;
          }
        ];
      };

      configHome = pkgs.linkFarm "hip-backup-config-home" [
        { name = "hip/config.yaml"; path = hipConfig; }
      ];

      gitConfig = pkgs.writeText "hip-backup-gitconfig" ''
        [credential "https://github.com"]
          helper = "!f() { test \"$1\" = get && echo username=x-access-token && echo \"password=$HIP_GITHUB_TOKEN\"; }; f"
      '';

      syncScript = pkgs.writeShellScript "hip-backup-sync" ''
        HIP_GITHUB_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/github-token")"
        export HIP_GITHUB_TOKEN
        exec ${lib.getExe hip} sync
      '';
    in
    {
      age.secrets.hip-backup-github-token.file = ../../../secrets/hip-backup-github-token.age;

      users.groups.${user} = { };
      users.users.${user} = {
        isSystemUser = true;
        group = user;
        home = stateDir;
      };

      systemd.services.hip-repo-backup = {
        description = "Sync GitHub repositories with hip for backup";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [ pkgs.git ];
        environment = {
          HOME = stateDir;
          XDG_CONFIG_HOME = "${configHome}";
          XDG_CACHE_HOME = "${stateDir}/cache";
          GIT_CONFIG_GLOBAL = "${gitConfig}";
          GIT_TERMINAL_PROMPT = "0";
        };
        serviceConfig = {
          Type = "oneshot";
          User = user;
          Group = user;
          StateDirectory = user;
          StateDirectoryMode = "0750";
          LoadCredential = [ "github-token:${config.age.secrets.hip-backup-github-token.path}" ];
          ExecStart = syncScript;
        };
      };

      systemd.timers.hip-repo-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
}
