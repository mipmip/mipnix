{ config, lib, pkgs, ... }:

let
  cfg = config.programs.skull;
  iniFormat = pkgs.formats.yaml { };

  mipmip = {
    name = "Pim Snel";
    email = "post@pimsnel.com";
    github = "mipmip";
    githubId = 658612;
  };

  mkOptionRoot = description:
    lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = description;
    };

in {
  meta.maintainers = [ mipmip ];

  options.programs.skull = {

    enable = lib.mkEnableOption "Enable Skull";

    projects = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule [
          {
            options = {
              base_dir = mkOptionRoot ''
                Root path in filesystem of the skull project. This is where repos are cloned into

                Application defaults to `$HOME`.
              '';

              repos = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule [
                    {
                      options = {
                        source = lib.mkOption {
                          type = lib.types.str;
                          description = ''
                            source URI of repo
                          '';
                        };
                      };
                    }
                  ]);
              };
            };
          }
        ]);
    };

  };

  config =
    let
      projects = iniFormat.generate "skulls" cfg.projects;

    in lib.mkIf cfg.enable {
        home.file."${config.home.homeDirectory}/.config/skulls.yaml" = {
          source = projects;
        };
  };
}

