{
inputs,
...
}:
{
  flake.modules.homeManager.annemarie-myhotkeys = {
    home.file = {
      "./.config/myhotkeys/keys.json" = {
        source = ./myhotkeys.json;
      };
    };

  };
}
