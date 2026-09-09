{ ... }: {

  # Fonts that are not packaged in nixpkgs. Kept separate from
  # `flake.overlays.apps` (which overrides existing applications) and
  # registered in modules/nix/channels.nix.
  flake.overlays.fonts = _final: prev: {

    # Clear Sans — Intel's OpenType UI typeface. Not in nixpkgs, so it is built
    # from source here.
    #
    # Upstream publishes no git tags and no GitHub releases: the font binaries
    # live directly in the repository tree. Intel has also formally discontinued
    # the project ("This project will no longer be maintained by Intel"), so the
    # rev below is main's final HEAD and will not move. Hence the nixpkgs
    # untagged-version convention (`0-unstable-<commit date>`) rather than a
    # release number.
    clear-sans = prev.stdenvNoCC.mkDerivation {
      pname = "clear-sans";
      version = "0-unstable-2023-01-07";

      src = prev.fetchFromGitHub {
        owner = "intel";
        repo = "clear-sans";
        rev = "1993725b24a36af21e7ebaa8977103983b608572";
        hash = "sha256-+xdetdE3Z4NlrWiEYCUO5bmf06g/+p5blkkNk+XcruQ=";
      };

      # Upstream also ships EOT/SVG/WOFF for the web; only the TTFs are useful
      # to fontconfig.
      installPhase = ''
        runHook preInstall
        install -Dm444 TTF/*.ttf -t $out/share/fonts/truetype
        runHook postInstall
      '';

      meta = with prev.lib; {
        description = "OpenType font designed for on-screen legibility";
        homepage = "https://github.com/intel/clear-sans";
        license = licenses.asl20;
        platforms = platforms.all;
      };
    };
  };
}
