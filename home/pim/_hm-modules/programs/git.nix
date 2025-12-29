{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Pim Snel";
        email = "post@pimsnel.com";
      };

      init = {
        defaultBranch = "main";
      };
      safe = {
        directory = "/etc/nixos";
      };
    };
  };
}
