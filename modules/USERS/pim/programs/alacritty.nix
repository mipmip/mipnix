{
inputs,
...
}:
{
  flake.modules.homeManager.pim-alacritty = {
    programs.alacritty = {
      enable = true;

      settings = {
        window.padding = {
          x = 10;
          y = 10;
        };
        font.normal = {
          family = "DejaVu Sans Mono";
          style = "Regular";
        };
      };
    };
  };
}
