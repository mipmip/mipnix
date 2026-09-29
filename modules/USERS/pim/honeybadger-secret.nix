{ ... }: {
  flake.modules.nixos.secrets-honeybadger = { ... }: {

    age.secrets.honeybadger-conf = {
      file = ../../../secrets/honeybadger-conf.age;
      path = "/home/pim/.honeybadger.conf";
      symlink = false;
      owner = "pim";
      group = "users";
      mode = "600";
    };

  };
}
