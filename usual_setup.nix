{ config, pkgs, ... }:

with pkgs.lib;
let
  emacsPkg = if pkgs.stdenv.isDarwin then pkgs.emacsMacport else pkgs.emacs26;
  phpLanguageServer = import ./deps/php-language-server/default.nix { inherit pkgs; };
  dracula = pkgs.tmuxPlugins.mkDerivation {
    pluginName = "dracula";
    version = "unstable-2020-09-20";
    src = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "tmux";
      rev = "85ce8a8b4a4b8bfcc3614b2dd8345f30f5ea091b";
      sha256 = "0k1f3chhmnv6f2022cj58j3nyv6ssaqadvnvcc6bzk0y9ha70gnl";
    };
  };
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

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [
        yank fzf-tmux-url
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-show-weather false
            set -g @dracula-military-time true
            set -g @dracula-cpu-usage true
            set -g @dracula-ram-usage true
            set -g @dracula-show-network false
          '';
        }

      ];
    };

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
    dua
    _1password
    gibo

    zstd
    gnutar

    graphviz
    plantuml
    ditaa

    niv
    rustup

    w3m
    phpLanguageServer
    nodePackages.typescript-language-server
    global
    ctags
    clang-tools
  ] ++ optionals stdenv.isDarwin [ lorri reattach-to-user-namespace ]
  ++ optional stdenv.isLinux xsel;

  home.file = {
    ".emacs.d/init.el".source = ./init.el;
  };
}
