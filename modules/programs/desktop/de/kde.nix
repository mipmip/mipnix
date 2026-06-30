{ inputs, ... } : {
  flake.modules.nixos.desktop-de-kde = { config, pkgs, ... }: {
    services.desktopManager.plasma6.enable = true;

    environment.sessionVariables = {
      # Primary fix: force Qt apps to use the native KDE/Plasma file dialog
      # instead of the GTK3 one. A GNOME layer present on this host otherwise
      # pushes Qt towards the gtk3 platform theme; KDEPlasmaPlatformTheme is the
      # only installed Qt platform theme here, so "kde" keeps Qt apps on the
      # Plasma dialogs and avoids the GTK3 file-chooser path entirely.
      #
      # Symptom this fixes: KMail aborts (SIGTRAP) when clicking "attach file"
      # in a new mail — it opened the GTK3 QFileDialog, which calls
      # g_settings_new("org.gtk.Settings.FileChooser"); that schema was not on
      # the GSettings search path, and GLib does a fatal abort on a missing
      # schema.
      QT_QPA_PLATFORMTHEME = "kde";

      # Safety net: make the GTK3 GSettings schemas (incl.
      # org.gtk.Settings.FileChooser) discoverable so that *any* GTK3 file
      # dialog under Plasma cannot abort, even if something still selects the
      # gtk3 theme. nixpkgs' glib setup-hook relocates each package's schemas to
      # share/gsettings-schemas/<name>/ (to avoid collisions); GNOME's
      # desktop-manager re-adds those dirs to XDG_DATA_DIRS, but Plasma does not.
      # The FileChooser schema ships in gtk3 specifically (not in
      # gsettings-desktop-schemas). This mirrors what GNOME's module does.
      XDG_DATA_DIRS = [
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      ];
    };
  };
}

