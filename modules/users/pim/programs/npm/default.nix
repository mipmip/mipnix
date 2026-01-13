{
inputs,
...
}:
{
  flake.modules.homeManager.pim-npm = {
    home.file = {
      ".npmrc" = {
        source = ./.npmrc;
      };
    };
  };
}
