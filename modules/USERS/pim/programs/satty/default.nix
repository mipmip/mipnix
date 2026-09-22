{
inputs,
...
}:
{
  # satty's configuration. The package itself is installed system-wide from the
  # Hyprland desktop module, next to hyprshot; this only supplies the behaviour.
  flake.modules.homeManager.pim-satty = {
    home.file = {
      ".config/satty/config.toml" = {
        source = ./config.toml;
      };
    };
  };
}
