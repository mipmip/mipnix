{ ... }:
{
  flake.modules.homeManager.pim-rbw = { config, pkgs, ... }: {

    # rbw, an unofficial Bitwarden CLI. ragenx reads the ssh key it hands to
    # agenix out of rbw, so the two travel together.
    #
    # pinentry-tty keeps the prompt in the terminal, so it works over ssh and
    # outside a Gnome session. pinentry-gnome3 wants gcr's dbus service.
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vaultwarden.notnix.com";
        email = "post@pimsnel.com";
        lock_timeout = 7200;
        pinentry = pkgs.pinentry-tty;
      };
    };

    systemd.user.services.rbw-agent = {
      Unit = {
        Description = "rbw agent, the unlock daemon for the Bitwarden CLI";
        PartOf = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${config.programs.rbw.package}/bin/rbw-agent --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
