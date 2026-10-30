{
  inputs = {


    # GRANNYOS
    nixpkgs-mama.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-mama-moving.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    #zonnehoed / janine
    nixpkgs-zonnehoed.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable-hyprland.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-boot-grannyos.url = "github:mipmip/nixos-boot-grannyos";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware-t2.url = "github:nixos/nixos-hardware";

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "unstable";
    };

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Track the nixvim release branch matching nixpkgs (26.05); `main` follows
    # nixpkgs-unstable and warns about a version mismatch.
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    hm-ricing-mode.url = "github:mipmip/hm-ricing-mode";
    hm-ricing-mode.inputs.nixpkgs.follows = "nixpkgs-2505";

    agenix.url = "github:ryantm/agenix";

    bmc.url = "github:wearetechnative/bmc";
    race.url = "github:wearetechnative/race";

    jsonify-aws-dotfiles.url = "github:mipmip/jsonify-aws-dotfiles";
    myhotkeys.url = "github:mipmip/gnome-hotkeys.cr/0.2.7";

    dirty-repo-scanner.url = "github:mipmip/dirty-repo-scanner";
    jjay.url = "github:speclib/jjay";
    teejay.url = "github:mipmip/teejay";
    specgetty.url = "github:speclib/specgetty";
    verynix.url = "github:mipmip/verynix";
    rme.url = "github:mipmip/rme";

    # ragenx: decrypt/rekey agenix secrets with an ssh key held in rbw, without
    # writing the private key to disk. Its agenix follows ours so the two do not
    # pull separate copies of ryantm/agenix.
    ragenx.url = "github:torreirow/ragenx";
    ragenx.inputs.nixpkgs.follows = "nixpkgs";
    ragenx.inputs.agenix.follows = "agenix";

    skull.url = "github:mipmip/skull";
    mip.url = "github:mipmip/mip.rs";
    hypr-network-manager.url = "github:mipmip/hypr-network-manager";
    fred.url = "github:linden-project/fred";
    linny-mcp.url = "github:linden-project/linny-mcp-server";
    linny-mcp.inputs.nixpkgs.follows = "nixpkgs";
    startaste.url = "github:mipmip/startaste";
    startaste.inputs.nixpkgs.follows = "nixpkgs";
    hip.url = "github:mipmip/hip";
    beandex.url = "github:mipmip/beandex";

    # The two halves of the prefix + M monitoring popup. Both were invoked as
    # `nix run github:mipmip/...` from the smug monitoring session; a popup
    # bound to a key cannot pay for a flake resolution, and a monitor that
    # needs the network up is no use for reporting that the network is down.
    nping.url = "github:mipmip/nping";
    nping.inputs.nixpkgs.follows = "nixpkgs";
    updo.url = "github:mipmip/updo";
    updo.inputs.nixpkgs.follows = "nixpkgs";

    nivis.url = "github:nivis-project/nivis";
    nivis.inputs.nixpkgs.follows = "nixpkgs";

    beans-nvim.url = "github:mipmip/beans.nvim";
    beans-nvim.flake = false;

    humanizer.url = "github:blader/humanizer";
    humanizer.flake = false;

    dutch-style-guide.url = "github:lboshuizen/dutch-style-guide";
    dutch-style-guide.flake = false;

    opencode-beans = {
      url = "github:mipmip/opencode-beans";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-openspec-sidepanel = {
      url = "github:speclib/opencode-openspec-sidepanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # REMOVE
    aoe.url = "github:njbrake/agent-of-empires";

    # The shop, renamed from mintglasinlood/voorzetramenshop. The module and the
    # package inside the repo still carry the old name, so only the input name
    # and the URL move; `services.voorzetramenshop` and the database do not.
    studio-mint-v1.url = "git+ssh://git@github.com/mintglasinlood/v1.studio-mint.shop.git";
    studio-mint-v1.inputs.nixpkgs.follows = "nixpkgs";

    studio-mint-v3.url = "git+ssh://git@github.com/mintglasinlood/v3.studio-mint.shop.git";
    studio-mint-v3.inputs.nixpkgs.follows = "nixpkgs";

    # The two static sites. Plain HTML, so no flake of their own: each arrives
    # as a bare store path and flake.nix turns it into a served directory, the
    # same way packages/pimsnel-website is handled.
    studio-mint-apex.url = "git+ssh://git@github.com/mintglasinlood/studio-mint.shop.git";
    studio-mint-apex.flake = false;

    studio-mint-v2.url = "git+ssh://git@github.com/mintglasinlood/v2.studio-mint.shop.git";
    studio-mint-v2.flake = false;

    nixpkgs-pine64.url = "nixpkgs/dfd82985c273aac6eced03625f454b334daae2e8";
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/efbe2c3c5409c868309ae0770852638e623690b5";
      flake = false;
    };
    home-manager-pine64.url = "github:nix-community/home-manager/release-22.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nivis-tunnel.url = "github:nivis-project/nivis-tunnel";
    nivis-tunnel.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];

      # Preserve templates
      flake.templates = {
        default = {
          path = ./templates/devshell;
          description = ''
            A minimal flake using flake-parts.
          '';
        };
      };

      # Optional: per-system outputs (formatter, devShells, etc.)
      perSystem = { system, pkgs, ... }:
        let
          pkgs-unstable = import inputs.unstable {
            inherit system;
            config.allowUnfree = true;
          };

          nixvimLib = inputs.nixvim.lib.${system};
          nixvim' = inputs.nixvim.legacyPackages.${system};
          pkgs-nixvim = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          nixvimModule = {
            pkgs = pkgs-nixvim;
            module = {
              imports = [
                (inputs.import-tree ./packages/mipvim/config)
              ];
            };
            extraSpecialArgs = {
              inherit inputs;
              mipColors = import ./lib/colors.nix;
            };
          };

          mipbar-astalPackages = with inputs.ags.packages.${system}; [
            io
            astal4
            hyprland
            network
            battery
            tray
            wireplumber
            bluetooth
          ];

          mipbar-extraPackages = mipbar-astalPackages ++ [
            pkgs-unstable.libadwaita
            pkgs-unstable.libsoup_3
          ];
        in
        {
          packages.mipvim = nixvim'.makeNixvimWithModule nixvimModule;
          checks.mipvim = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;

          # Unit tests for mipbar's pure helpers. widget/displays.ts imports
          # nothing from GTK or AGS precisely so its arithmetic (scale snapping,
          # mode deduplication, density) can be tested headless: esbuild strips
          # the types, node runs the result.
          checks.mipbar-displays = pkgs.runCommand "mipbar-displays-tests"
            {
              nativeBuildInputs = [ pkgs.esbuild pkgs.nodejs ];
              src = ./packages/mipbar;
            }
            ''
              cp -r $src/. ./mipbar
              esbuild --bundle ./mipbar/widget/displayInfo.test.ts \
                --outfile=./tests.js --platform=node --log-level=warning
              node ./tests.js
              touch $out
            '';

          checks.mipbar-camera = pkgs.runCommand "mipbar-camera-tests"
            {
              nativeBuildInputs = [ pkgs.esbuild pkgs.nodejs ];
              src = ./packages/mipbar;
            }
            ''
              cp -r $src/. ./mipbar
              esbuild --bundle ./mipbar/widget/cameraUsers.test.ts \
                --outfile=./tests.js --platform=node --log-level=warning
              node ./tests.js
              touch $out
            '';

          checks.mipbar-last-notification =pkgs.runCommand "mipbar-last-notification-tests"
            {
              nativeBuildInputs = [ pkgs.esbuild pkgs.nodejs ];
              src = ./packages/mipbar;
            }
            ''
              cp -r $src/. ./mipbar
              esbuild --bundle ./mipbar/state/notification.test.ts \
                --outfile=./tests.js --platform=node --log-level=warning
              node ./tests.js
              touch $out
            '';

          devShells.default = pkgs.mkShell {
            buildInputs = [
              (inputs.ags.packages.${system}.default.override {
                extraPackages = mipbar-extraPackages;
              })
            ];
          };

          packages.mipbar = pkgs-unstable.stdenv.mkDerivation {
            name = "mipbar";
            src = ./packages/mipbar;

            nativeBuildInputs = with pkgs-unstable; [
              wrapGAppsHook3
              gobject-introspection
              librsvg # rsvg-convert: rasterize device SVGs to PNG at build time
              inputs.ags.packages.${system}.default
            ];

            buildInputs = mipbar-extraPackages ++ [ pkgs-unstable.gjs ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin
              mkdir -p $out/share
              cp -r * $out/share

              # Tests are a build-time check (checks.mipbar-displays), not part
              # of the shipped bundle.
              rm -f $out/share/widget/*.test.ts
              rm -f $out/share/state/*.test.ts

              # Rasterize device illustrations to PNG so the runtime never needs
              # an SVG pixbuf loader. deviceImage() loads these from $SRC/assets.
              for svg in $out/share/assets/*.svg; do
                rsvg-convert -w 116 -h 84 "$svg" -o "''${svg%.svg}.png"
              done

              ags bundle app.ts $out/bin/mipbar \
                -d "SRC='$out/share'" \
                -d "ASKPASS='${pkgs-unstable.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass'"

              ln -s ${pkgs-unstable.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass $out/bin/askpass

              runHook postInstall
            '';
          };

          packages.pimsnel-website = pkgs.runCommand "pimsnel-website" {} ''
            mkdir -p $out
            cp -r ${./packages/pimsnel-website}/* $out/
          '';

          # The two static Studio MINT sites. Their inputs are `flake = false`,
          # so the whole repository is the store path: without the `rm` the
          # README would be served next to index.html.
          packages.studio-mint-apex = pkgs.runCommand "studio-mint-apex" {} ''
            mkdir -p $out
            cp -r ${inputs.studio-mint-apex}/* $out/
            rm -f $out/README.md
          '';

          packages.studio-mint-v2 = pkgs.runCommand "studio-mint-v2" {} ''
            mkdir -p $out
            cp -r ${inputs.studio-mint-v2}/* $out/
            rm -f $out/README.md
          '';

            # Lint Text generated by AI
            packages.prose-lint = pkgs.runCommand "prose-lint" { } ''
            mkdir -p $out/bin
            {
              echo '#!${pkgs.python3}/bin/python3'
              cat ${./packages/prose-lint/prose_lint.py}
            } > $out/bin/prose-lint
            substituteInPlace $out/bin/prose-lint \
              --replace-fail '@FILLER_WORDS@' '${./packages/prose-lint/filler-words.json}'
            chmod +x $out/bin/prose-lint
          '';

          checks.prose-lint = pkgs.runCommand "prose-lint-tests"
            {
              nativeBuildInputs = [ pkgs.python3 ];
              src = ./packages/prose-lint;
            }
            ''
              cp -r $src/. ./prose-lint
              cd ./prose-lint
              python3 test_prose_lint.py
              touch $out
            '';
        };
    };
}
