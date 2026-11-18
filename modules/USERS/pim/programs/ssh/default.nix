{
  inputs,
  ...
}:
{
  flake.modules.homeManager.pim-ssh = { pkgs, config, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ssh-key-state
    ];

    services.ssh-agent.enable = true;

    systemd.user.services.ssh-agent.Service.ExecStartPre =
      "-${pkgs.coreutils}/bin/rm -f %t/${config.services.ssh-agent.socket}";

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".AddKeysToAgent = "yes";
    };

    systemd.user.sessionVariables.SSH_AUTH_SOCK = "%t/ssh-agent";
  };
}
