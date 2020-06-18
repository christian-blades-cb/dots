{ config, pkgs, ... }:

with pkgs.lib;
let
  emacsPkg = if pkgs.stdenv.isDarwin then pkgs.emacsMacport else pkgs.emacs;
in {
  services = optionalAttrs pkgs.stdenv.isLinux { lorri.enable = true; };

  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;

      shellAbbrs = {
        ll = "${pkgs.exa}/bin/exa -l";
        l = "${pkgs.exa}/bin/exa";
      };
    };

    emacs = {
      enable = true;
      package = emacsPkg;
    };

    fzf = {
      enable = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f";
      enableFishIntegration = true;
    };

    direnv.enable = true;
    starship.enable = true;
    bat.enable = true;
    jq.enable = true;
    texlive.enable = true;
  };

  home.packages = with pkgs; [
    # font love
    fira-code
    fira-code-symbols

    fd
    xsv
    ripgrep
    exa

    zstd
    gnutar

    graphviz
    plantuml
    # texlive.combined.scheme-basic

    niv
    rustup
  ] ++ optional stdenv.isDarwin lorri;

  home.file = {
    ".emacs.d/init.el".source = ./init.el;
  };
}
