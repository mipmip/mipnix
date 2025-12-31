{ pkgs, ... }: {

  environment.systemPackages = [
   pkgs.git
   pkgs.home-manager
   pkgs.docker
   pkgs.lynis
   pkgs.neofetch
  ];

  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
}
