{
inputs,
...
}:
{
  flake.modules.nixos.role-server = {

    boot.kernelParams = [ "consoleblank=60" ];
    programs.mosh.enable = true;

    # Servers must never suspend/hibernate. Masking these targets is the
    # strongest guarantee: even a GNOME idle-suspend request or a closed
    # laptop lid cannot put the machine to sleep, because the sleep targets
    # themselves become unavailable.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    imports = with inputs.self.modules.nixos; [
    ];
  };
}

