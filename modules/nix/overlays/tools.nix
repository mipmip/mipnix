{ ... }: {

  # Tools that are not packaged in nixpkgs, built from their own source. Kept
  # separate from `flake.overlays.apps` (which overrides existing applications)
  # and registered in modules/nix/channels.nix, the same arrangement the fonts
  # overlay uses.
  flake.overlays.tools = _final: prev: {

    # keyb renders a hotkey cheatsheet in the terminal. nixpkgs carries no
    # package for it (the near misses are keyd and CuboCore.corekeyboard), and
    # the source is upstream rather than in this repository, so it belongs in
    # an overlay rather than under packages/.
    #
    # Pinned to a tagged release: the hotkey file format is what this
    # configuration generates against, and a moving branch could change it.
    keyb = prev.buildGoModule rec {
      pname = "keyb";
      version = "0.8.0";

      src = prev.fetchFromGitHub {
        owner = "kencx";
        repo = "keyb";
        rev = "v${version}";
        hash = "sha256-583+vAfku8OPFX2pXFJFwEGRnZx3a4Cj6ywwJ6QYQ/o=";
      };

      vendorHash = "sha256-fQkYYrMC48NbDW0yqNuV1VAC0XbRIQad7Iy2/P8Yubw=";

      ldflags = [ "-s" "-w" "-X main.version=${version}" ];

      meta = with prev.lib; {
        description = "Create and view custom hotkey cheatsheets in the terminal";
        homepage = "https://github.com/kencx/keyb";
        license = licenses.mit;
        mainProgram = "keyb";
        platforms = platforms.unix;
      };
    };
  };
}
