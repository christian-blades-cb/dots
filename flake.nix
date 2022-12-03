{
  description = "NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?rev=30ec7dc6416c7b3d286d047ec905eaf857f712f9";
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
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, yabai-src, ... }: rec {
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
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              nix.package = pkgs.nixFlakes;
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
              nixpkgs.overlays = (nixpkgs.lib.attrValues overlays) ++ [ inputs.nixgl.overlay ];

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
              home.stateVersion = "20.09";

              targets.genericLinux.enable = true;

              home.username = "cblades";
              home.homeDirectory = "/Users/blades";              
            }
            ./parkour.nix
            ./usual_setup.nix
            ./personal.nix
            ./personal_git.nix
            ./personal_gmail.nix
          ];
        };
    };
  };
}
