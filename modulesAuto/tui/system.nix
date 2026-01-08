{ pkgs, ...}: {

  environment.systemPackages = with pkgs; [

    #SYSTEM
    htop
    util-linux
    sysstat
    iotop
    binutils
    gettext
    psmisc
    file
    neofetch
    fastfetch
  ];
}
