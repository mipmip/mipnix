{ ... }: {
  flake.modules.nixos.nix-github-token = { config, ... }: let
    tokenFile = config.age.secrets.ghi-token.path;
    systemFragment = "/etc/nix/access-tokens.conf";
    userFragment = "/home/pim/.config/nix/access-tokens.conf";
  in {

    age.secrets.ghi-token = {
      file = ../../secrets/ghi-token.age;
      owner = "root";
      group = "root";
      mode = "600";
    };

    nix.extraOptions = ''
      !include ${systemFragment}
    '';

    system.activationScripts.nixAccessTokens = {
      deps = [ "agenix" "users" "groups" ];
      text = ''
        if [ -r ${tokenFile} ]; then
          token=$(cat ${tokenFile})

          install -m 600 -o root -g root /dev/null ${systemFragment}
          printf 'access-tokens = github.com=%s\n' "$token" > ${systemFragment}

          for dir in /home/pim/.config /home/pim/.config/nix; do
            [ -d "$dir" ] || install -d -m 755 -o pim -g users "$dir"
          done

          install -m 600 -o pim -g users /dev/null ${userFragment}
          printf 'access-tokens = github.com=%s\n' "$token" > ${userFragment}

          unset token
        fi
      '';
    };

  };
}
