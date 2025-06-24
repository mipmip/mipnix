{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    bumper.url = "github:VTimofeenko/writing-flake-modules?dir=example-1-configurable-inputs-bumper/provider";
  };

  outputs =
  inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.devshell.flakeModule
      inputs.bumper.flakeModule
    ];
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    perSystem = _: {
      devshells.default = { };
      bumper.changingInputs = [ "bumper" "devshell"];
      bumper.bumpAllInputs = true;
    };
  };
}
