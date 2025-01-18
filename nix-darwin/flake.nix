{
  description = "Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
	flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
	flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
	flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.mkalias
	    pkgs.git
	    pkgs.vim
          pkgs.neovim
	    pkgs.tmux
	    pkgs.fastfetch
	    pkgs.logseq
	    pkgs.yazi
	    pkgs.ripgrep
        ];

      # Homebrew
	homebrew = {
	  enable = true;
	  brews = [
	    "mas"
	    "emacs"
	    "ispell"
	    "pandoc"
	    "hugo"
	    "qemu"
	    "enchant"
	    "sass/sass/sass"
	  ];
	  casks = [
	    "whisky"
	    "heroic"
	    "ghostty"
	    "basictex"
	    "keepassxc"
	  ];
	  masApps = {
	    "Home Assistant" = 1099568401;
          "GoodLinks" = 1474335294;
	    "Bitwarden" = 1352778147;
	    "Focalboard" = 1556908618;
	    "Wireguard" = 1451685025;
	  };
	  onActivation.cleanup = "zap";
	  onActivation.autoUpdate = true;
	  onActivation.upgrade = true;
	};

	# Fonts
	fonts.packages = [
        pkgs.jetbrains-mono
	  pkgs.meslo-lg
	];

	# Activation script for aliasing applications
	system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
       pkgs.lib.mkForce ''
       # Set up applications.
       echo "Setting up /Applications..." >&2
       rm -rf /Applications/Nix\ Apps
       mkdir -p /Applications/Nix\ Apps
       find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
         while read -r src; do
           app_name=$(basename "$src")
           echo "Copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
         done
             '';

      # Configure macOS system settings with Nix.
	system.defaults = {
        dock.autohide = false;
	  finder.FXPreferredViewStyle = "clmv";
	  NSGlobalDomain.AppleInterfaceStyle = "Dark";
	  loginwindow.GuestEnabled = false;
	  NSGlobalDomain.KeyRepeat = 2;
	};

	# Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

	# Allow unsupported packages
	nixpkgs.config.allowUnsupportedSystem = true;
    };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook-Pro
    darwinConfigurations."MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
	  configuration 
        nix-homebrew.darwinModules.nix-homebrew
	  {
	    nix-homebrew = {
	      enable = true;
		enableRosetta = true;
		user = "Jordan";
		autoMigrate = true;
	    };
	  }
	];

    # Expose the package set, including overlays, for convenience.
    # darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
    };
  };
}
