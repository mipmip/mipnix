{ ... }:
{
  flake.modules.homeManager.pim-rbw = { pkgs, ... }: {

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
  };
}
