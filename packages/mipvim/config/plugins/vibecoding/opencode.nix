{ lib, ... }:
{
  plugins.opencode = {
    enable = true;
    settings = {
      auto_reload = true;
      #port = 9090;
    };
  };
}
