{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
	({ pkgs, ...}: {
          programs.neovim.defaultEditor = true;
	})
      ];
    };

    packages.x86_64-linux.hello = pkgs.hello;

    packages.x86_64-linux.default = pkgs.hello;

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [ pkgs.neovim ];
    };

  };
}
