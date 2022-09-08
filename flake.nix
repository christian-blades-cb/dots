{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    yabai-src = {
      url = "github:koekeishiya/yabai";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    gke-gcloud.url = "github:christian-blades-cb/gke-gcloud-auth-plugin-nix";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, yabai-src, ... }: rec {
    overlays.nur = inputs.nur.overlay;
    overlays.gke-gcloud = inputs.gke-gcloud.overlays.default;
    overlays.fenix = inputs.fenix.overlay;

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
  };
}
