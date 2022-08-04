{ config, pkgs, ... }:
{
  programs.go = {
    enable = true;
    goPrivate = [ "*.rsglab.com" ];
    # packages = {
    #   "golang.org/x/tools" = builtins.fetchGit {
    #     url = "git@github.com:golang/tools.git";
    #     ref = "v0.1.12";
    #     rev = "b3b5c13b291f9653da6f31b95db100a2e26bd186";
    #   };
    # };
  };

  home.packages = with pkgs; [
    # gcloud cli
    google-cloud-sdk

    # standard golang tools
    gotools
    mockgen
    golangci-lint
  ];
}
