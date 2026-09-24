{ ... }:
{
  flake.modules.homeManager.pim-rbw = { pkgs, ... }: {

    # rbw, an unofficial Bitwarden CLI. ragenx reads the ssh key it hands to
    # agenix out of rbw, so the two travel together.
    #
    # Not configured through `programs.rbw`: that module needs the account's
    # email address, which is account data rather than machine configuration.
    # Two commands finish the setup on a new machine:
    #
    #   rbw config set email <address>
    #   rbw config set pinentry pinentry-gnome3
    #
    # pinentry is installed here so the second command resolves. rbw reads the
    # program name out of its own config, so putting it on PATH alone does
    # nothing. pinentry-gnome3 wants gcr's dbus service; if the prompt never
    # appears, `rbw config set pinentry pinentry-curses` works from a terminal.
    home.packages = with pkgs; [
      rbw
      pinentry-gnome3
    ];
  };
}
