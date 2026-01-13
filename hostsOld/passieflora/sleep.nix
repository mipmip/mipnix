{ config, lib, pkgs, modulesPath, ... }:

{
  # Suspend Workaround
  # https://wiki.t2linux.org/guides/postinstall/#suspend-workaround
  #  systemd.services.suspend-fix-t2 = {
  #    description = "Disable and Re-Enable Apple BCE Module (and Wi-Fi)";
  #
  #    unitConfig = {
  #      StopWhenUnneeded = "yes";
  #    };
  #
  #    serviceConfig = {
  #      User = "root";
  #      RemainAfterExit = "yes";
  #
  #      # TODO: Do rmmod and modprobe need to be declaratively defined?
  #      ExecStart = "/run/current-system/sw/bin/rmmod -f apple-bce";
  #      ExecStop = "/run/current-system/sw/bin/modprobe apple-bce";
  #    };
  #
  #    before = [ "sleep.target" ];
  #    wantedBy = [ "sleep.target" ];
  #  };

  # make the laptop use s2idle to prevent closing the lid from cooking it
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  # Just give up and disable suspend
  # systemd.sleep.extraConfig = ''
  #   AllowSuspend=no
  #   AllowHibernation=no
  #   AllowHybridSleep=no
  #   AllowSuspendThenHibernate=no
  # '';
}
