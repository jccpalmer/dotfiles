# NixOS Home Manager configuration #
####################################

  { config, pkgs, lib, flake-inputs, ... }:

  {

    # Imports
    imports = [
      ./protonmail-bridge.nix
    ];

    # Home Manager settings
    programs.home-manager.enable = true;
    home.stateVersion = "25.05";

    # User settings
    home.username = "jordan";
    home.homeDirectory = "/home/jordan";

    # User package management
    home.packages = with pkgs; [
      
      # Archival tools
      zip
      xz
      unzip
      p7zip

      # Networking tools
      mtr
      iperf3
      dnsutils
      ldns
      aria2
      socat
      nmap
      ipcalc

      # Utilities
      fastfetch
      nnn
      ripgrep
      jq
      yq-go
      fzf

      # Misc
      cowsay
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg

      # Nix
      nix-output-monitor

	# Emacs
	emacs

      # Productivity
      libreoffice-fresh
	bitwarden
      logseq
      hugo
      glow
      protonmail-bridge
      mullvad-vpn
	nextcloud-client

      # Browser
      brave

      # System monitors
      btop
      iotop
      iftop
      strace
      ltrace
      lsof

      # System tools
      sysstat
      lm_sensors
      ethtool
      pciutils
      usbutils
      kdePackages.kwalletmanager
      kdePackages.kwallet-pam
	pinentry-qt
	tmux

      # Gaming
      steam
      lutris
      #heroic
      protonup-qt
      protontricks
      discord
      gamemode
      gamescope

      # WINE
      wine
      winetricks

	# Photos
	gimp
	darktable

      # ZSH settings
      oh-my-zsh
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];

    # Programs

    programs.git = {
      enable = true;
      userName = "JC Palmer";
      userEmail = "me@jccpalmer.com";
    };

    programs.zsh = {
      enable = true;
  #   enableCompletion = true;
  #   autosuggestions.enable = true;
  #   syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -l";
	  u = "sudo nixos-rebuild switch --flake ~/.config/nixos";
   	  n = "nvim";
   	  s = "sudo";
	  x = "nix flake update --flake ~/.config/nixos";
	  g = "git push origin HEAD:main";
	  gp = "git pull origin main";
	  gc = "git commit -m";
      };

   #   histSize = 10000;
    };

    # Services

    services.gpg-agent = {
      enable = true;
	pinentryPackage = pkgs.pinentry-qt;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    

    services.protonmail-bridge = {
      enable = true;
      #package =
        #pkgs.runCommand "protonmail-bridge" {
	    #bridge = pkgs.protonmail-bridge;
	    #nativeBuildInputs = [ pkgs.makeWrapper ];
	  #}
	  #''
	  #mkdir -p $out/bin
	  #makeWrapper $bridge/bin/protonmail-bridge $out/bin/protonmail-bridge \
	  #  --set PATH ${lib.strings.makeBinPath [ pkgs.kdePackages.kwalletmanager ]}
        #'';
    };

    # SystemD configuration

    systemd.user.startServices = "sd-switch";

    ## Overlays

    nixpkgs.overlays = [
      (
        final: prev: {
	    logseq = prev.logseq.overrideAttrs (oldAttrs: {
	      postFixup = ''
	        makeWrapper ${prev.electron_20}/bin/electron $out/bin/${oldAttrs.pname} \
	        --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
		  --add-flags $out/share/${oldAttrs.pname}/resources/app \
		  --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
		  --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.stdenv.cc.cc.lib ]}"
	        '';
	      });
	    }
        )
      ];
  }
