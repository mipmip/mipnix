{ inputs, self, ... }:

let
  hostname = "clawone";
in
{

  flake.modules.nixos.clawone = { config, pkgs, lib, ... }:
  let
    openclaw-pim = pkgs.writeShellScriptBin "openclaw-pim" ''
      exec env \
        HOME=/var/lib/openclaw \
        OPENCLAW_CONFIG_PATH=/var/lib/openclaw/openclaw.json \
        OPENCLAW_STATE_DIR=/var/lib/openclaw \
        PATH=/var/lib/openclaw/.npm-global/bin:${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin \
        /var/lib/openclaw/.npm-global/bin/openclaw "$@"
    '';
    openclaw-janine = pkgs.writeShellScriptBin "openclaw-janine" ''
      exec env \
        HOME=/var/lib/openclaw-janine \
        OPENCLAW_CONFIG_PATH=/var/lib/openclaw-janine/openclaw.json \
        OPENCLAW_STATE_DIR=/var/lib/openclaw-janine \
        PATH=/var/lib/openclaw-janine/.npm-global/bin:${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin \
        /var/lib/openclaw-janine/.npm-global/bin/openclaw "$@"
    '';
  in
  {
    system.stateVersion = "25.11";

    imports = [
      inputs.agenix.nixosModules.default
    ];

    microvm = {
      hypervisor = "qemu";
      vcpu = 2;
      mem = 2049;

      interfaces = [{
        type = "tap";
        id = "vm-clawone";
        mac = "02:00:00:00:01:01";
      }];

      volumes = [{
        mountPoint = "/var";
        image = "clawone-var.img";
        size = 8192;
      }];

      shares = [{
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "virtiofs";
      }];
    };

    # OpenClaw workspace documents - Pim
    environment.etc."openclaw/workspace/AGENTS.md".source = ./documents/AGENTS.md;
    environment.etc."openclaw/workspace/SOUL.md".source = ./documents/SOUL.md;
    environment.etc."openclaw/workspace/TOOLS.md".source = ./documents/TOOLS.md;

    # OpenClaw workspace documents - Janine
    environment.etc."openclaw-janine/workspace/AGENTS.md".source = ./documents-janine/AGENTS.md;
    environment.etc."openclaw-janine/workspace/SOUL.md".source = ./documents-janine/SOUL.md;
    environment.etc."openclaw-janine/workspace/TOOLS.md".source = ./documents-janine/TOOLS.md;

    # System users
    users.users.openclaw = {
      isSystemUser = true;
      group = "openclaw";
      home = "/var/lib/openclaw";
      createHome = true;
      shell = pkgs.bashInteractive;
    };
    users.groups.openclaw = {};

    users.users.openclaw-janine = {
      isSystemUser = true;
      group = "openclaw-janine";
      home = "/var/lib/openclaw-janine";
      createHome = true;
      shell = pkgs.bashInteractive;
    };
    users.groups.openclaw-janine = {};

    # System packages
    environment.systemPackages = with pkgs; [
      # Runtime
      nodejs_22 bash git

      # CLI wrappers
      openclaw-pim
      openclaw-janine

      # Core utils
      coreutils findutils gnugrep gnused gawk
      diffutils patch less file which tree
      procps htop

      # Network
      curl wget jq

      # Archives
      zip unzip gnutar gzip bzip2 xz zstd p7zip

      # Text & documents
      pandoc poppler_utils    # PDF tools (pdftotext, pdfinfo)
      ghostscript             # PDF/PS processing
      imagemagick             # Image conversion
      csvkit                  # CSV processing
      libxml2                 # xmllint
      html-tidy               # HTML processing
      dos2unix                # Line ending conversion

      # Data & formats
      yq-go                   # YAML/TOML processing
      sqlite                  # SQLite databases
      miller                  # CSV/JSON/tabular data

      # Dev tools
      ripgrep fd bat
      python3
    ];

    # Pim: install openclaw via npm
    systemd.services.openclaw-install = {
      description = "Install OpenClaw via npm (pim)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "openclaw";
        Group = "openclaw";
        WorkingDirectory = "/var/lib/openclaw";
        Environment = [
          "HOME=/var/lib/openclaw"
          "PATH=${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
          "npm_config_prefix=/var/lib/openclaw/.npm-global"
        ];
        ExecStart = "${pkgs.bash}/bin/bash -c 'test -x /var/lib/openclaw/.npm-global/bin/openclaw || ${pkgs.nodejs_22}/bin/npm install -g openclaw'";
      };
    };

    # Pim: gateway service
    systemd.services.openclaw-gateway = {
      description = "OpenClaw gateway (pim)";
      after = [ "network-online.target" "openclaw-install.service" ];
      wants = [ "network-online.target" ];
      requires = [ "openclaw-install.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "openclaw";
        Group = "openclaw";
        WorkingDirectory = "/var/lib/openclaw";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "HOME=/var/lib/openclaw"
          "OPENCLAW_CONFIG_PATH=/var/lib/openclaw/openclaw.json"
          "OPENCLAW_STATE_DIR=/var/lib/openclaw"
          "PATH=/var/lib/openclaw/.npm-global/bin:${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
        ];
        ExecStart = "/var/lib/openclaw/.npm-global/bin/openclaw gateway --port 18789";
      };
    };

    # Janine: install openclaw via npm
    systemd.services.openclaw-install-janine = {
      description = "Install OpenClaw via npm (janine)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "openclaw-janine";
        Group = "openclaw-janine";
        WorkingDirectory = "/var/lib/openclaw-janine";
        Environment = [
          "HOME=/var/lib/openclaw-janine"
          "PATH=${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
          "npm_config_prefix=/var/lib/openclaw-janine/.npm-global"
        ];
        ExecStart = "${pkgs.bash}/bin/bash -c 'test -x /var/lib/openclaw-janine/.npm-global/bin/openclaw || ${pkgs.nodejs_22}/bin/npm install -g openclaw'";
      };
    };

    # Janine: gateway service
    systemd.services.openclaw-gateway-janine = {
      description = "OpenClaw gateway (janine)";
      after = [ "network-online.target" "openclaw-install-janine.service" ];
      wants = [ "network-online.target" ];
      requires = [ "openclaw-install-janine.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "openclaw-janine";
        Group = "openclaw-janine";
        WorkingDirectory = "/var/lib/openclaw-janine";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "HOME=/var/lib/openclaw-janine"
          "OPENCLAW_CONFIG_PATH=/var/lib/openclaw-janine/openclaw.json"
          "OPENCLAW_STATE_DIR=/var/lib/openclaw-janine"
          "PATH=/var/lib/openclaw-janine/.npm-global/bin:${pkgs.nodejs_22}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:/run/current-system/sw/bin"
        ];
        ExecStart = "/var/lib/openclaw-janine/.npm-global/bin/openclaw gateway --port 18790";
      };
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    security.sudo.wheelNeedsPassword = false;

    users.users.pim = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEY25ZaYRuKUJuVuzqK4c8dKkSxN6Cd9yhbDTa/5Njmh"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };

}
