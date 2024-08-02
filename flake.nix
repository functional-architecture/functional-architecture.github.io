{
  description = "Commands for developing the functional-architecture.org website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        jekyllFull = pkgs.jekyll.override {
          # this way jekyll knows all the necessary plugins
          withOptionalDependencies = true;
        };
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "build-blog";
            src = pkgs.lib.cleanSource ./.;
            buildInputs = [ jekyllFull ];
            installPhase = "cp -r . $out";
          };
          serveBlog = pkgs.writeShellScriptBin "serve-blog" "${pkgs.lib.getExe jekyllFull} serve --watch";
        };

        apps.default = flake-utils.lib.mkApp { drv = self.packages.${system}.serveBlog; };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            jekyllFull
            self.formatter.${system}
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
