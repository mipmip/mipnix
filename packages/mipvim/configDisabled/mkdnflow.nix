_: {
  plugins.mkdnflow = {
    enable = false;
    settings = {
      modules = {
        conceal = false;
        links = false;
      };
      links = {
        #conceal = true;
        style = "wiki";
      };

      to_do.symbols = [
        " "
        "x"
        "!"
      ];
      mappings = {
        MkdnToggleToDo = {
          key = "-";
          modes = [
            "n"
            "v"
          ];
        };
      };
    };

  };
}
