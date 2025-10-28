{pkgs,...} :

{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-failed = true
    '';

    package = pkgs.nixVersions.stable;

    #    settings.trusted-substituters = [
    #      "http://attic.tools.technative.cloud:8080/smartmc"
    #    ];
    #    settings.extra-substituters = [
    #      "http://attic.tools.technative.cloud:8080/smartmc"
    #    ];
    #    settings.extra-trusted-public-keys = [
    #      "smartmc:uix5eOnUkmqH6VzKToVNFyEr7PNUmXKt1QDQqVdv2XA="
    #    ];

  };
}
