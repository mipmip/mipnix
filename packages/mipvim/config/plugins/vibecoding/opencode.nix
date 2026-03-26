{ lib, ... }:
{
  plugins.opencode = {
    enable = true;
    settings = {
      auto_reload = true;
      #port = 9090;
    };
  };

  #  plugins.claude-code = {
  #    enable = true;
  #    #keymaps = {
  #    #  "<leader>cc" = "<cmd>ClaudeCode<CR>";
  #    #};
  #    settings = {
  #      window = {
  #        position = "rightbelow vsplit";
  #      };
  #    };
  #  };

  #  keymaps = [
  #   {
  #      mode = [ "n" ];
  #      key = "<leader>aa";
  #      action = lib.nixvim.mkRaw ''function() require("opencode").ask() end'';
  #      options.desc = "AI: Ask a question";
  #    }
  #  ];
}
