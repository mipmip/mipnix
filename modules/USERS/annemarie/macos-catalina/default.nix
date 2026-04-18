{
  inputs,
  ...
}:
{
  flake.modules.homeManager.annemarie-macos-catalina = {

    home.file.".local/bin/start-macos-catalina.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        cd /home/annemarie
        ./macos-catalina/setup-network.sh
        exec ./macos-catalina/macos-catalina.sh
      '';
    };

    home.file.".local/share/icons/macos-catalina.png" = {
      source = ./macos-catalina.png;
    };

    xdg.desktopEntries.macos-catalina = {
      name = "macOS Catalina";
      comment = "Start macOS Catalina QEMU VM";
      genericName = "Virtual Machine";
      exec = "/home/annemarie/.local/bin/start-macos-catalina.sh";
      categories = [ "System" "Emulator" ];
      terminal = false;
      startupNotify = true;
      type = "Application";
      icon = "macos-catalina";
    };
  };
}
