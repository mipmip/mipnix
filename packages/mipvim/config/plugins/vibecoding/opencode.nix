{ lib, ... }:
{
  plugins.opencode = {
    enable = true;
    settings = {
      auto_reload = true;
      #port = 9090;
    };
  };

  #  keymaps = [
  #   {
  #      mode = [ "n" ];
  #      key = "<leader>aa";
  #      action = lib.nixvim.mkRaw ''function() require("opencode").ask() end'';
  #      options.desc = "AI: Ask a question";
  #    }
  #  ];
}
