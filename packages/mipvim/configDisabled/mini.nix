{
  plugins.mini = {
    enable = false;

    modules = {
      indentscope = {
        draw.delay = 100;
        symbol = "│";
        options = {
          try_as_border = true;
        };
      };
      surround = { };
    };
  };
}
