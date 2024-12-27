# NixOS Flake configuration #
#############################

{
  description = "Nix Flake configuration for Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
      # pkgs = "nixpkgs.legacyPackages.x86_64-linux";
        specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.jordan = import ./home.nix;
        # extraSpecialArgs = { inherit inputs; };
         }
       ];
      };
    };
  };
}
