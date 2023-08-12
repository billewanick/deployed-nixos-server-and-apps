{
  description = "A Nix flake for my long-running seal blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    utils.url = "github:numtide/flake-utils";

    spg.url = "git+https://git.ewanick.com/bill/sealPostGenerator.git";
    spg.inputs.nixpkgs.follows = "nixpkgs";
    spg.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        ghc' = pkgs.haskellPackages.ghcWithHoogle (self: with self; [
          hakyll
        ]);
      in
      rec {
        apps.generateSealPosts = {
          type = "app";
          program = "${inputs.spg.packages.${system}.default}/bin/generateSealPosts";
        };

        apps.hakyll-site = {
          type = "app";
          program = "${packages.default}/bin/site";
        };

        apps.default = apps.hakyll-site;

        packages.default = pkgs.stdenv.mkDerivation {
          name = "site";
          src = self;
          buildPhase = ''
            ${ghc'}/bin/ghc \
              -O2           \
              -static       \
              -o site       \
              site.hs
          '';
          installPhase = "mkdir -p $out/bin; install -t $out/bin site";
        };

        devShells.default = pkgs.mkShell {
          name = "hakyll-shell";

          buildInputs = with pkgs.haskellPackages; [
            ghc'
            hlint
            haskell-language-server
          ];
        };
      });
}
