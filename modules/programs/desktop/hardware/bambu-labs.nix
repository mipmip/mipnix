{ inputs, ... }: {
  flake.modules.nixos.desktop-hw-bambu-labs = { config, lib, pkgs, ... }:
    let
      version = "02.04.00.70";

      appimageSource = pkgs.fetchurl {
        url =
          "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-24.04_PR-8834.AppImage";
        hash = "sha256-JrwH3MsE3y5GKx4Do3ZlCSAcRuJzEqFYRPb11/3x3r0=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        pname = "bambu-studio";
        inherit version;
        src = appimageSource;
      };

      bambu-studio = pkgs.appimageTools.wrapType2 rec {
        pname = "bambu-studio";
        inherit version;
        src = appimageSource;

        profile = ''
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/"
          export WEBKIT_DISABLE_DMABUF_RENDERER=1
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export MESA_LOADER_DRIVER_OVERRIDE=nvidia
        '';

        extraPkgs = pkgs:
          with pkgs; [
            cacert
            curl
            glib
            glib-networking
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            webkitgtk_4_1
          ];

        extraInstallCommands = ''
          install -Dm644 ${appimageContents}/BambuStudio.desktop $out/share/applications/BambuStudio.desktop
          substituteInPlace $out/share/applications/BambuStudio.desktop \
            --replace 'Exec=AppRun' 'Exec=bambu-studio' \
            --replace 'Icon=BambuStudio' 'Icon=bambu-studio'

          mkdir -p $out/share/pixmaps
          cp ${appimageContents}/resources/images/BambuStudioLogo.png $out/share/pixmaps/bambu-studio.png 2>/dev/null || \
          cp ${appimageContents}/.DirIcon $out/share/pixmaps/bambu-studio.png 2>/dev/null || true
        '';
      };
    in { environment.systemPackages = [ bambu-studio ]; };
}
