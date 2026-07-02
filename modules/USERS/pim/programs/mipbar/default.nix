{
inputs,
...
}:
{
  flake.modules.homeManager.pim-mipbar = { pkgs, ... }: {

    home.packages = [
      inputs.self.packages."${pkgs.stdenv.hostPlatform.system}".mipbar
      inputs.hypr-network-manager.packages."${pkgs.stdenv.hostPlatform.system}".default
      pkgs.brightnessctl
      pkgs.socat
      pkgs.lxqt.lxqt-openssh-askpass
    ];

    # The SshKey widget's click-to-load calls `ssh-add` from the detached bar
    # process, which has no controlling tty — the passphrase prompt must come
    # from an askpass helper. The gcr agent ships its own askpass, but it
    # refuses standalone invocation ("not meant to be run directly"): it only
    # works when driven by gcr's own prompter, not as a generic SSH_ASKPASS.
    # So pin a standalone askpass and force ssh-add to use it.
    home.sessionVariables = {
      SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
      SSH_ASKPASS_REQUIRE = "force";
    };

    programs.hm-ricing-mode.apps.mipbar = {
      dest_dir = ".config/mipbar";
      source_dir = "$HOME/mipnix/packages/mipbar";
      type = "symlink";
    };

  };
}
