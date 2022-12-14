{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {};
in
  {
    nixpkgs.overlays = [ (self: super: { inherit (unstable) home-assistant; })];

    # disabledModules = [ "services/misc/home-assistant.nix" ];

    # imports = [
    #   "${<nixos-unstable>}/nixos/modules/services/misc/home-assistant.nix"
    # ];

    # services.home-assistant = {
    #   enable = true;
    #   package = (pkgs.home-assistant.override {
    #     extraPackages = py: with py; [ psycopg2 ];
    #     extraComponents = [ "deconz" ];
    #   });
    #   config.recorder.db_url = "postgresql://@//hass";
    # };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "hass" ];
      ensureUsers = [{
        name = "hass";
        ensurePermissions = {
          "DATABASE hass" = "ALL PRIVILEGES";
        };
      }];
    };

    networking.firewall.allowedTCPPorts = [ 8123 ];
  }
