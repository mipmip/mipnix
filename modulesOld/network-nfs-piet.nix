{ config, lib, pkgs, modulesPath, ... }:

{
  #  fileSystems."/mnt/piethein-hurwenen-share" = {
  #    device = "192.168.178.37:/volume1/HurwenenShare";
  #    fsType = "nfs";
  #    options = [ "x-systemd.automount" "noauto" ];
  #  };
  #  fileSystems."/mnt/piethein-archief" = {
  #    device = "192.168.178.37:/volume1/Archief";
  #    fsType = "nfs";
  #    options = [ "x-systemd.automount" "noauto" ];
  #  };
#  fileSystems."/mnt/piethein-cathalijne-archief" = {
#    device = "192.168.178.37:/volume1/CathalijneArchief";
#    fsType = "nfs";
#    options = [ "x-systemd.automount" "noauto" ];
#  };
  #  fileSystems."/mnt/piethein-annemarie-in-de-kast" = {
  #    device = "192.168.178.37:/volume1/Annemarie-in-de-kast";
  #    fsType = "nfs";
  #    options = [ "x-systemd.automount" "noauto" ];
  #  };
}
