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

    # Bypass gcr/gnome-keyring for SSH and run a plain openssh ssh-agent.
    #
    # gcr-ssh-agent (a forwarding shim to gnome-keyring) was `SSH_AUTH_SOCK`,
    # but gnome-keyring would keep the passphrase-protected key in its listing
    # while being unable to sign with it — so `ssh-add -l` reported "loaded" yet
    # SSH auth stalled right after "Server accepts key", and nothing (ssh-add
    # -d/-D, re-add, agent restart) could clear the phantom listing. A plain
    # ssh-agent starts empty and signs normally, so the SshKey widget's
    # load/unload actually work. See [[mipnix-mipbar-ssh-key-indicator]].
    services.ssh-agent.enable = true;

    # An agent that is killed rather than stopped leaves its socket behind,
    # and the next start refuses with "cannot bind to path
    # /run/user/1000/ssh-agent: Address already in use" and stays dead until
    # somebody removes the file by hand. The OOM killer did exactly that on
    # 2 November 2026. HM's unit has no pre-start cleanup, so this adds one;
    # the leading "-" lets the start carry on when there is nothing to remove.
    systemd.user.services.ssh-agent.Service.ExecStartPre =
      "-${pkgs.coreutils}/bin/rm -f %t/${config.services.ssh-agent.socket}";

    # The key has a passphrase, so it has to be typed in once per agent.
    # AddKeysToAgent makes the first ssh that needs it hand it to the agent,
    # which turns that into once per boot rather than once per tool: git, jj
    # and ssh itself stop asking each other's questions. The prompt still
    # appears on the tty, because SSH_ASKPASS is deliberately not set
    # session-wide (see the note at the bottom of this module).
    #
    # This makes HM own ~/.ssh/config, which nothing wrote before.
    # enableDefaultConfig would add ten unrelated defaults and warn that it is
    # going away, so the file holds only what is asked for here.
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".AddKeysToAgent = "yes";
    };

    # Point the whole graphical session (GUI apps + mipbar, not just login
    # shells — which is all HM's services.ssh-agent sets) at the plain agent's
    # socket, so it wins over any gcr-exported SSH_AUTH_SOCK. `%t` is
    # $XDG_RUNTIME_DIR; the HM ssh-agent service listens on %t/ssh-agent.
    systemd.user.sessionVariables.SSH_AUTH_SOCK = "%t/ssh-agent";

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
