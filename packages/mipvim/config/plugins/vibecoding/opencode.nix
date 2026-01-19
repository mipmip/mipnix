{ lib, ... }:
{
  plugins.opencode = {
    enable = true;
  };

  keymaps = [
    {
      mode = [ "n" ];
      key = "<leader>aa";
      action = lib.nixvim.mkRaw ''function() require("opencode").ask() end'';
      options.desc = "AI: Ask a question";
    }
  ];
}
