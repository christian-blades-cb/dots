{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs?rev=30ec7dc6416c7b3d286d047ec905eaf857f712f9";
    darwin.url = "github:lnl7/nix-darwin?rev=4182ad42d5fb5001adb1f61bec3a04fae0eecb95";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    yabai-src = {
      url = "github:koekeishiya/yabai";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    gke-gcloud.url = "github:christian-blades-cb/gke-gcloud-auth-plugin-nix";
    gke-gcloud.inputs.nixpkgs.follows = "nixpkgs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghz.url = "github:christian-blades-cb/ghz-flake";
    ghz.inputs.nixpkgs.follows = "nixpkgs";
    govuln.url = "github:christian-blades-cb/govulncheck-flake";
    govuln.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, yabai-src, nixos-hardware, ... }: rec {
    overlays = {
      nur = inputs.nur.overlay;
      gke-gcloud = inputs.gke-gcloud.overlays.default;
      fenix = inputs.fenix.overlay;
      govuln = inputs.govuln.overlay;
      ghz = inputs.ghz.overlay;
    };

    darwinConfigurations = {
      "macos-C02GQ06Z1PG3" = darwin.lib.darwinSystem {
       system = "x86_64-darwin";
        specialArgs = { inherit yabai-src; };
        modules = [
          ./darwin-configuration.nix
          ./work-darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.cblades = import ./work-home.nix;
            nixpkgs.overlays = nixpkgs.lib.attrValues overlays;
            nixpkgs.config.allowUnfree = true;

            users.users.cblades = {
              shell = nixpkgs.fish;
              description = "Christian Blades";
              home = "/Users/cblades";
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };

    homeConfigurations = {
      parkour = let
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
              nixpkgs.overlays = (nixpkgs.lib.attrValues overlays) ++ [ inputs.nixgl.overlay ];

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
              home.stateVersion = "20.09";

              targets.genericLinux.enable = true;

              home.username = "blades";
              home.homeDirectory = "/home/blades";
            }
            ./parkour.nix
            ./usual_setup.nix
            ./personal.nix
            ./personal_git.nix
            ./personal_gmail.nix
          ];
        };

    };


    nixosConfigurations = {
      parkour = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./parkour/configuration.nix
          ./parkour/thinkpad_fan.nix
          ./tailscale.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nixpkgs.overlays = (nixpkgs.lib.attrValues overlays) ++ [ inputs.nixgl.overlay ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.blades = (
              { config, pkgs, ... }:
              {
                home.stateVersion = "20.09";

                targets.genericLinux.enable = true;

                imports = [
                  ./parkour.nix
                  ./usual_setup.nix
                  ./personal.nix
                  ./personal_git.nix
                  ./personal_gmail.nix
                ];
              }
            );
          }
        ];
      };

      inchhigh = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./inchhigh/configuration.nix
          ./inchhigh/hardware-configuration.nix
          ./tailscale.nix
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            # nixpkgs.overlays = (nixpkgs.lib.attrValues overlays);
          }
        ];
      };

      inchhigh-cdimage = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./inchhigh/configuration.nix
          ./inchhigh/hardware-configuration.nix
          "${nixpkgs}/nixos/modules/installer/iso-image.nix"
          ./tailscale.nix
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            # nixpkgs.overlays = (nixpkgs.lib.attrValues overlays);
          }
        ];
      };

      relay = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./relay/configuration.nix
          ./relay/znc.nix
          ./tailscale.nix
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          { swapDevices = [ { device = "/var/lib/swapfile"; size = 2 * 1024; } ]; }
        ];
      };

      relay-container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./relay/configuration.nix
          ./relay/znc.nix
          # ./tailscale.nix
          # "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          # { swapDevices = [ { device = "/var/lib/swapfile"; size = 2 * 1024; } ]; }
          { boot.isContainer = true; networking.firewall.allowedTCPPorts = [ 5000 ]; }
        ];
      };

      # nix build .#nixosConfigurations.itg-mastodon-oracle-arm.config.system.build.OCIImage
      itg-mastodon-oracle-arm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./oracle-cloud/oci-options.nix
          ./oracle-cloud/oci-image.nix

          ./itg-mastodon/configuration.nix
          ./itg-mastodon/backups.nix
          ./itg-mastodon/sendgrid.nix

          ./user-blades.nix
          ./tailscale.nix
          ({ pkgs, ... }: {
            services.openssh.enable = true;
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;

            # do the dance to get the right env for `tootctl`
            users.users.blades.packages = let
              tootctlScript = pkgs.writeShellScriptBin "tootctl" ''
                sudo su -s ${pkgs.bash}/bin/bash -l -c "mastodon-env tootctl $*" - mastodon
              '';
            in [ tootctlScript ];
          })
        ];
      };
      
    };

    packages.x86_64-linux.nixosConfigurations = self.nixosConfigurations;
  };
}
