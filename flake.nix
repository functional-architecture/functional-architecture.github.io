{
  description = "Website for Functional Software Architecture";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, ...}@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ inputs.ocaml-overlay.overlays.default ];
        pkgs = import nixpkgs { inherit system overlays; };
        legacyPackages = nixpkgs.legacyPackages.${system};
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages;
        lib = legacyPackages.lib;

        sources = {
          ocaml = nix-filter.lib {
            root = ./.;
            include = [
              ".ocamlformat"
              "dune-project"
              (nix-filter.lib.inDirectory "bin")
              (nix-filter.lib.inDirectory "lib")
              (nix-filter.lib.inDirectory "test")
            ];
          };

          nix = nix-filter.lib {
            root = ./.;
            include = [
              (nix-filter.lib.matchExt "nix")
            ];
          };
        };
      in
        {
          packages = {
            default = self.packages.${system}.funarch;

            funarch = ocamlPackages.buildDunePackage {
              pname = "funarch";
              version = "0.1.0";
              duneVersion = "3";
              src = sources.ocaml;

              buildInputs = [
                ocamlPackages.tyxml
                ocamlPackages.sexplib
                ocamlPackages.omd
                ocamlPackages.lwt_ppx
              ];

              strictDeps = true;

              preBuild = ''
                dune build funarch.opam
              '';
            };
          };
          devShells = {
            default = pkgs.mkShell {
              # Development tools
              packages = [
                # Merlin
                ocamlPackages.merlin
                # Opam
                ocamlPackages.opam-core
                # Source file formatting
                legacyPackages.nixpkgs-fmt
                legacyPackages.ocamlformat
                # For `dune build --watch ...`
                legacyPackages.fswatch
                # OCaml editor support
                ocamlPackages.ocaml-lsp
                # Nicely formatted types on hover
                ocamlPackages.ocamlformat-rpc-lib
                # Fancy REPL thing
                ocamlPackages.utop
              ];

              # Tools from packages
              inputsFrom = [
                self.packages.${system}.funarch
              ];
            };
          };
        }
    );
}
