{ inputs, ... } : {

  flake.modules.nixos.networking-netboot = { pkgs, config, ... }: {

    services.pixiecore = {
      enable = true;
      dhcpNoBind = true; # Use existing DHCP server.
      openFirewall = true;
      #mode = "api";

      # https://carlosvaz.com/posts/ipxe-booting-with-nixos/
      # kernel = "https://boot.netboot.xyz";
      # kernel = "${netboot}/bzImage";

      kernel = "https://boot.netboot.xyz";


    };
  };
}
