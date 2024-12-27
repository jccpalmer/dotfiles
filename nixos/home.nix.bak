# NixOS Home Manager configuration #
####################################

  { config, pkgs, ... }:

  {
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

      #Utilities
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

      # Productivity
      libreoffice-fresh
      logseq
      hugo
      glow

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

      # Gaming
      steam
      lutris
      heroic
      protonup-qt
      protontricks
      discord
      gamemode
      gamescope
      discord

      # WINE
      wine
      winetricks

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
   	 n = "neovim";
   	 s = "sudo";
      };

   #   histSize = 10000;
    };

    # Services
    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

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

    home.stateVersion = "25.05";
    programs.home-manager.enable = true;
  }
