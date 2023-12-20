{ config, pkgs, ... }:

with pkgs.lib;
let
  emacsPkg = if pkgs.stdenv.isDarwin then pkgs.emacsMacport else pkgs.emacs28;
  phpLanguageServer = import ./deps/php-language-server/default.nix { inherit pkgs; };
  draculaTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
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
  draculaKitty = ./deps/kitty-dracula/Dracula.conf;
in {
  services = optionalAttrs pkgs.stdenv.isLinux { lorri.enable = true; };

  nixpkgs.config.allowUnfree = true;

  # Install MacOS applications to the user environment if the targetPlatform is Darwin
  # home.file."Applications/home-manager".source = let
  #   apps = pkgs.buildEnv {
  #     name = "home-manager-applications";
  #     paths = config.home.packages;
  #     pathsToLink = "/Applications";
  #   };
  # in mkIf pkgs.stdenv.targetPlatform.isDarwin "${apps}/Applications";

  programs = {
    firefox = {
      enable = true;
      # package = pkgs.runCommand "firefox-0.0.0" { } "mkdir $out";
      package = if pkgs.stdenv.isDarwin then pkgs.nur.repos.toonn.apps.firefox else pkgs.firefox;
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   ublock-origin
      # ];
    };

    fish = {
      enable = true;
      shellAliases = {
        ll = "${pkgs.eza}/bin/eza -l";
        lla = "${pkgs.eza}/bin/eza -la";
        l = "${pkgs.eza}/bin/eza";
      };
      plugins = [
        {
          name = "google-cloud-sdk-fish-completion";
          src =   pkgs.fetchFromGitHub {
            owner = "lgathy";
            repo = "google-cloud-sdk-fish-completion";
            rev = "bc24b0bf7da2addca377d89feece4487ca0b1e9c";
            sha256 = "03zzggi64fhk0yx705h8nbg3a02zch9y49cdvzgnmpi321vz71h4";
            fetchSubmodules = true;
          };
        }
      ];
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
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        nix_shell.disabled = true;
        gcloud.format = "on [$symbol$project]($style) ";
        gcloud.symbol = "☁️";
        nodejs.symbol = "⬢ ";
      };
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

            set -g default-command ${pkgs.fish}/bin/fish
          '';
        }
      ];
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    kitty = {
      enable = true;
      font = {
        package = pkgs.fira-code-symbols;
        name = "Fira Code";
        # types = "Fira Code";
        # size = 12;
      };
      extraConfig = ''
        include ${draculaKitty}
      '';
    };

    bat = {
      enable = true;
      themes = {
        dracula = builtins.readFile (pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "sublime";
          rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
          sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
        } + "/Dracula.tmTheme");
      };
      config = {
        theme = "Dracula";
      };
    };

    alacritty.enable = true;
    jq.enable = true;
    texlive.enable = true;
    gpg.enable = true;

    pandoc = {
      enable = true;
      defaults = {
        metadata.author = "Christian Blades";
      };
    };
  };

  home.packages = with pkgs; [
    # font love
    fira-code
    fira-code-symbols

    dig
    binutils
    fd
    xsv
    ripgrep
    eza
    dua
    # _1password
    gibo
    bottom
    # youtube-dl
    # mpd
    mpc_cli
    sqlite

    xz
    zstd
    gnutar

    graphviz
    plantuml
    ditaa

    niv
    rustup
    # rust-analyzer-nightly
    cargo-nextest

    dhall
    dhall-json
    dhall-lsp-server

    w3m
    # phpLanguageServer
    nodePackages.typescript-language-server
    global
    ctags
    clang-tools
    python3Packages.yapf

    (aspellWithDicts (p: with p; [en en-computers en-science]))
  ] ++ optionals stdenv.isDarwin [ lorri reattach-to-user-namespace ]
  ++ optional stdenv.isLinux xsel;

  # aspell dicts
  home.file.".aspell.conf".text = ''
    master en_US
    extra-dicts en-computers.rws
    add-extra-dicts en_US-science.rws
  '';

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
    linuxLogfile = "syslog";
    darwinLogfile = "~/.config/mpd/mpg.log";
    logFile = if pkgs.stdenv.isDarwin then darwinLogfile else linuxLogfile;

  in ''
    ${(pkgs.lib.optionalString pkgs.stdenv.isLinux linuxAudio)}
    ${(pkgs.lib.optionalString pkgs.stdenv.isDarwin darwinAudio)}

    music_directory    "~/Music"
    db_file            "~/.config/mpd/database"
    playlist_directory "~/.config/mpd/playlists"
    pid_file           "~/.config/mpd/mpd.pid"
    state_file         "~/.config/mpd/state"
    log_file           "${logFile}"
    auto_update        "yes"

    bind_to_address    "127.0.0.1"
    port               "6600"
  '';
}
