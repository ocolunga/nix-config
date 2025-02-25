{
  description = "NixOS and Nix-Darwin configuration for all my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mac-dev
      darwinConfigurations."mac-dev" = nix-darwin.lib.darwinSystem {
        modules = [
          ./nix-darwin/dev.nix
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "ocolunga";
            };
          }
        ];
      };
    };
}
