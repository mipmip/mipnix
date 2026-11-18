{
inputs,
...
}:
{
  flake.modules.homeManager.pim-mipbar = { pkgs, config, ... }: {

    home.packages = [
      inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".mipbar
      inputs.hypr-network-manager.packages."${pkgs.stdenv.hostPlatform.system}".default
      pkgs.brightnessctl
      pkgs.socat
      pkgs.lxqt.lxqt-openssh-askpass
    ];

    # Mask gcr's ssh-agent (socket + service) so it can't claim /run/user/*/gcr/ssh
    # or export a competing SSH_AUTH_SOCK. A unit *symlinked* to /dev/null is a
    # systemd mask; use mkOutOfStoreSymlink so HM creates a symlink rather than
    # trying to copy the /dev/null device node into the store (which errors with
    # "unsupported type"). gnome-keyring keeps secrets/passwords; only its SSH
    # role is dropped.
    xdg.configFile = {
      "systemd/user/gcr-ssh-agent.socket".source =
        config.lib.file.mkOutOfStoreSymlink "/dev/null";
      "systemd/user/gcr-ssh-agent.service".source =
        config.lib.file.mkOutOfStoreSymlink "/dev/null";
    };

    # NB: SSH_ASKPASS / SSH_ASKPASS_REQUIRE are intentionally NOT set as session
    # variables. Setting SSH_ASKPASS_REQUIRE=force session-wide made *every*
    # ssh/ssh-add (e.g. `ssh pim@lavendel` in a terminal) pop the GUI askpass
    # instead of prompting on the tty. The SshKey widget instead sets these env
    # vars inline on its own `ssh-add` invocation (see SshKey.tsx), so the GUI
    # passphrase popup appears ONLY when clicking the widget's Load button; plain
    # terminal ssh keeps its normal tty prompt. The standalone askpass binary is
    # still installed (home.packages above) and its path is baked into the mipbar
    # bundle at build time (ASKPASS define in flake.nix).

    programs.hm-ricing-mode.apps.mipbar = {
      dest_dir = ".config/mipbar";
      source_dir = "$HOME/mipnix/packages/mipbar";
      type = "symlink";
    };

  };
}
