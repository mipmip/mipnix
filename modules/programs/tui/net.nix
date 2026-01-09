{ inputs, ... } : {
  flake.modules.nixos.tui-net = { config, pkgs, ... }: {
    environment.systemPackages = with pkgs; [

      dstp # Run common networking tests against your site

      #DNS
      bind.dnsutils
      whois

      #NFS
      nfs-utils

      #SSH
      mosh

      #HTTP
      wget
      httpie
      xh


    ];
  };
}
