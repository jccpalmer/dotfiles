# Proton Mail Bridge configuration #
####################################

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.protonmail-bridge;

in {
  options = {

    services.protonmail-bridge = {
      enable = mkOption {
        type = types.bool;
	  default = false;
	  description = "Whether to enable the Bridge.";
	};

	package = mkOption {
        type = types.package;
	  default = pkgs.protonmail-bridge;
	  defaultText = literalExpression "pkgs.protonmail-bridge";
	  description = "The Proton Mail Bridge package to use.";
	};

	logLevel = mkOption {
        type = types.enum [
          "panic"
	    "fatal"
	    "error"
	    "warn"
	    "info"
	    "debug"
	  ];
	  default = "info";
	  description = "The log level.";
	};
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge";
	  After = [ "network.target" ];
	};

	Service = {
        Restart = "always";
	  ExecStart = "${cfg.package}/bin/protonmail-bridge --no-interactive --log-level ${cfg.logLevel}";
	};

	Install = {
        WantedBy = [ "default.target" ];
	};
    };
  };
}
