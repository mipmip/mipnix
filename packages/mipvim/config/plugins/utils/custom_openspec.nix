{ pkgs, ... }:
let
  tree-sitter-openspec-src = pkgs.fetchFromGitHub {
    owner = "speclib";
    repo = "tree-sitter-openspec";
    rev = "4ce350b";
    hash = "sha256-tbA/I56dEj6jyZwT8NcfDNDTfEiGq95rqVtF8DgNj7g=";
  };

  tree-sitter-openspec = pkgs.stdenv.mkDerivation {
    pname = "tree-sitter-openspec";
    version = "0.1.0";
    src = tree-sitter-openspec-src;

    nativeBuildInputs = [ pkgs.gcc ];

    buildPhase = ''
      $CC -shared -o openspec_spec.so -fPIC \
        -I openspec_spec/src \
        openspec_spec/src/parser.c
    '';

    installPhase = ''
      mkdir -p $out/parser $out/queries
      cp openspec_spec.so $out/parser/openspec_spec.so
      cp -r queries/openspec_spec $out/queries/openspec_spec
    '';
  };
in
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "openspec.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "speclib";
        repo = "openspec.nvim";
        rev = "00fc1d55c5f59134827676cada08a96f703cd641";
        hash = "sha256-572rQOzKr3nfnLWr7zEBEk+teCTB/TX0tvbuJQknEaI=";
      };
    })

    tree-sitter-openspec
  ];

  extraConfigLua = ''
    require("openspec").setup({ neotree = true })
  '';
}
