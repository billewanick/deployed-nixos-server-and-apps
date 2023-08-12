{
  description = "System flake for Linode NixOS server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = inputs@{ nixpkgs, ... }:
    {
      nixosConfigurations.linode-nixos =
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
        in
        nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
          ];
        };
    };
}
