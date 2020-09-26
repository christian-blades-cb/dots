{ config, pkgs, ... }:

with pkgs.lib;
let
  emacsPkg = if pkgs.stdenv.isDarwin then pkgs.emacsMacport else pkgs.emacs26;
  phpLanguageServer = import ./deps/php-language-server/default.nix { inherit pkgs; };
  draculaTmux = pkgs.tmuxPlugins.mkDerivation {
    pluginName = "dracula";
    version = "unstable-2020-09-20";
    src = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "tmux";
      rev = "85ce8a8b4a4b8bfcc3614b2dd8345f30f5ea091b";
      sha256 = "0k1f3chhmnv6f2022cj58j3nyv6ssaqadvnvcc6bzk0y9ha70gnl";
    };
  };
  draculaAlacritty = let
    src = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "alacritty";
      rev = "9579552396a5341ea3717980ecf58c661149c8f9";
      sha256 = "1q6dwj9c8yipbqvydnrmc4kwsflrkix8i51nhn4n23k9sqa9wjz1";
    };
  in "${src}/dracula.yml";
in {
  services = optionalAttrs pkgs.stdenv.isLinux { lorri.enable = true; };

  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        ll = "${pkgs.exa}/bin/exa -l";
        lla = "${pkgs.exa}/bin/exa -la";
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
          plugin = draculaTmux;
          extraConfig = ''
            set -g @dracula-show-weather false
            set -g @dracula-military-time true
            set -g @dracula-cpu-usage true
            set -g @dracula-ram-usage true
            set -g @dracula-show-network false

            set-option -g default-shell ${pkgs.fish}/bin/fish
          '';
        }
      ];
    };

    alacritty.enable = true;
    bat.enable = true;
    jq.enable = true;
    texlive.enable = true;
    gpg.enable = true;
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
    gotop
    youtube-dl
    mpd
    mpc_cli

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
  xdg.configFile."alacritty/alacritty.yml".text = ''
    import:
      - ${draculaAlacritty}
    font:
      normal:
        family: FiraCode
  '';
  xdg.configFile."mpd/mpd.conf".text = let
    linuxAudio = ''
      audio_output {
        type            "pulse"
        name            "pulse audio"
      }
    '';
    darwinAudio = ''
      audio_output {
        type                  "osx"
        name                  "CoreAudio"
        mixer_type            "software"
      }
    '';
  in ''
    ${(pkgs.lib.optionalString pkgs.stdenv.isLinux linuxAudio)}
    ${(pkgs.lib.optionalString pkgs.stdenv.isDarwin darwinAudio)}

    music_directory    "~/Music"
    db_file            "~/.config/mpd/database"
    playlist_directory "~/.config/mpd/playlists"
    pid_file           "~/.config/mpd/mpd.pid"
    state_file         "~/.config/mpd/state"
    log_file           "syslog"
    auto_update        "yes"

    bind_to_address    "127.0.0.1"
    port               "6600"
  '';
}
