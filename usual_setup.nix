{ config, pkgs, ... }:

{
  services.lorri.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;

      shellAbbrs = {
        ll = "${pkgs.exa}/bin/exa -l";
        l = "${pkgs.exa}/bin/exa";
      };

      interactiveShellInit = ''
      ${pkgs.direnv}/bin/direnv hook fish | source
      ${pkgs.starship}/bin/starship init fish | source
      '';
    };
  };

  home.packages = with pkgs; [
    # font love
    fira-code
    fira-code-symbols

    fd
    xsv
    ripgrep
    fzf
    exa
    bat
    jq

    zstd
    gnutar

    direnv
    starship
  ];
}
