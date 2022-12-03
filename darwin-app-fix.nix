{ config, pkgs, ... }:

# Install MacOS applications to the user environment if the targetPlatform is Darwin
with pkgs.lib; mkIf pkgs.stdenv.targetPlatform.isDarwin {
  home.file."Applications/home-manager".source = let
    apps = pkgs.buildEnv {
      name = "home-manager-applications";
      paths = config.home.packages;
      pathsToLink = "/Applications";
    };
  in "${apps}/Applications";
}
