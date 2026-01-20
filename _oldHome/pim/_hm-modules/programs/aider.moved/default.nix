{ inputs, pkgs, ... }:

{

  home.file = {
    "./.aider.conf.yml" = {
      source = ./.aider.conf.yml;
    };
  };

}

