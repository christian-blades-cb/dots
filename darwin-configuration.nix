{ config, pkgs, yabai-src, ... }:

{
  # enable flake commands
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
    ];

  # put fish in the list of shells you can chsh
  environment.shells = with pkgs; [ zsh fish ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # caps lock delete
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # tiling window manager, I don't want to spend my days arranging windows
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      # layout
      layout = "bsp";
      auto_balance = "on";
      split_ratio = "0.50";
      window_placement = "second_child";
      # Gaps
      window_gap = 10;
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      # shadows and borders
      window_shadow = "off";
      window_border = "off";
      window_border_width = 3;
      window_opacity = "on";
      window_opacity_duration = "0.1";
      active_window_opacity = "1.0";
      normal_window_opacity = "1.0";
      # mouse
      mouse_modifier = "cmd";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";
    };
    package =
      let
        version = "4.0.1";
        buildSymlinks = pkgs.runCommand "build-symlinks" { } ''
          mkdir -p $out/bin
          ln -s /usr/bin/xcrun /usr/bin/xcodebuild /usr/bin/tiffutil /usr/bin/qlmanage $out/bin
        '';
      in
        pkgs.yabai.overrideAttrs ( old: {
          inherit version;
          src = yabai-src;

          buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
            Carbon
            Cocoa
            ScriptingBridge
            pkgs.xxd
            SkyLight
          ];

          nativeBuildInputs = [ buildSymlinks pkgs.installShellFiles ];
        });

  };

  # control yabai with the keyboard
  services.skhd = {
    enable = true;
    skhdConfig = ''
      # open terminal
      rcmd - return : kitty

      # toggle window zoom
      ralt - d : yabai -m window --toggle zoom-parent

      # focus window
      ralt - h : yabai -m window --focus west
      ralt - j : yabai -m window --focus south
      ralt - k : yabai -m window --focus north
      ralt - l : yabai -m window --focus east
    '';
  };

  # async nix-shell
  services.lorri.enable = true;

}
