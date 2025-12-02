{
  config.programs.command-not-found.enable = false;
  config.nix.extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      keep-failed = true
  '';
}
