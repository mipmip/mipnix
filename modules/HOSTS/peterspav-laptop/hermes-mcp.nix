{ inputs, ... }:
let
  meshIP = inputs.self.nebulaNodes.peterspav;
  port = 8766;
  publicHost = "hermes.pimsnel.com";

  python = pkgs: pkgs.python3.withPackages (ps: [ ps.mcp ps.httpx ps.uvicorn ps.starlette ]);
in
{
  lobby.services.hermes-mcp = {
    title = "Hermes MCP";
    description = "Give Hermes tasks from the Claude app; MCP over durer";
    host = "peterspav";
    url = "https://${publicHost}/mcp";
    access = "public";
    category = "tools";
    browse = false;
  };

  perSystem = { pkgs, ... }: {
    packages.hermes-mcp = pkgs.writeShellApplication {
      name = "hermes-mcp";
      text = ''
        exec ${python pkgs}/bin/python ${../../../packages/hermes-mcp/hermes_mcp.py} "$@"
      '';
    };

    checks.hermes-mcp = pkgs.runCommand "hermes-mcp-tests" { nativeBuildInputs = [ (python pkgs) ]; } ''
      cp ${../../../packages/hermes-mcp}/*.py .
      python test_hermes_mcp.py
      touch $out
    '';
  };

  flake.modules.nixos.peterspav = { config, pkgs, ... }: {
    age.secrets.hermes-mcp-token-hash.file = ../../../secrets/hermes-mcp-token-hash.age;

    systemd.services.hermes-mcp = {
      description = "MCP server that passes Claude's tasks to Hermes";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "nebula@mesh.service" "hermes-agent.service" ];
      wants = [ "network-online.target" ];
      environment = {
        HERMES_MCP_HOST = meshIP;
        HERMES_MCP_PORT = toString port;
        HERMES_MCP_ALLOWED_HOSTS = "${publicHost},${meshIP}:${toString port}";
        HERMES_MCP_FORWARDED_ALLOW_IPS = inputs.self.nebulaNodes.durer;
        HERMES_API_URL = "http://127.0.0.1:8642";
      };
      serviceConfig = {
        ExecStart = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hermes-mcp}/bin/hermes-mcp";
        EnvironmentFile = config.age.secrets.hermes-api-key.path;
        LoadCredential = "token-hash:${config.age.secrets.hermes-mcp-token-hash.path}";
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        CapabilityBoundingSet = "";
      };
    };
  };
}
