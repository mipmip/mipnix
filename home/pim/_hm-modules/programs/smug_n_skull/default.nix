{ lib, config, pkgs, ... }:

let
  cfg = config.desktopConf.smug;

  figletFonts = [ "poison" "doh" "starwars" "broadway" "cyberlarge" "doom" ];

  numberFromName = name:
    pkgs.lib.fromHexString
    (builtins.substring 0 15 (builtins.hashString "md5" name));

  # Implement modulo since builtins.mod doesn't exist
  mod = a: b: a - (b * (a / b));

  # Generating large Pseugo Random integers uniformly distributed over an range
  integerInRange = largeNumber: upperBound: mod largeNumber upperBound;

  makeBanner = text:
    let
      itemIndex =
        integerInRange (numberFromName text) (builtins.length figletFonts);
      pseudoRandomFont = builtins.elemAt figletFonts itemIndex;
    in "figlet -f ${pseudoRandomFont} '${text}' -w 200 | lolcat";

  makeSimpleProject = name: root: {
    root = root;
    windows = [{
      name = "fish ${builtins.toString (numberFromName name)}";
      layout = "main-vertical";
      commands = [ (makeBanner name) ];
    }];
  };

  simpleProjects = import ./simple_projects.nix;

  skullProjects = builtins.listToAttrs (lib.remove null (builtins.map (item:
    if builtins.hasAttr "repos" item then {
      name = item.name;
      value = {
        repos = item.repos;
        base_dir = item.root;
      };
    } else
      null) simpleProjects)) // import ./extra_skulls.nix;

in {
  options.desktopConf.smug = { enable = lib.mkEnableOption "Configure smug"; };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.figlet pkgs.lolcat ];

    programs = {
      skull = {
        enable = true;
        projects = skullProjects;
      };

      smug = {
        enable = true;
        projects = (import ./advanced_smugs.nix { inherit makeBanner; })
          // builtins.listToAttrs (builtins.map (item: {
            name = item.name;
            value = makeSimpleProject item.name item.root;
          }) simpleProjects);
      };

    };
  };
}
