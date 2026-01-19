_: {
  plugins = {
    quarto = {
      enable = true;
      settings = {
        lspFeatures = {
          enabled = true;
          languages = [
            "r"
            "python"
          ];
          chunks = "curly";
        };
        codeRunner = {
          enabled = false;
          default_method = "molten";
          diagnostics = {
            enabled = true;
            triggers = [ "BufWritePost" ];
          };
        };
      };
    };
    otter = {
      enable = true;
    };
  };
}
