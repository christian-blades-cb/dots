# blades' dotfiles

I'm managing my dotfiles via home-manager these days.

## Installing

1) Follow the installation instructions over at https://github.com/rycee/home-manager

2) Import the relevant modules in your `home.nix`

Example:

``` nix
# /home/blades/.config/nixpkgs/home.nix
{ config, pkgs, ... }:

let
  dots = "/home/blades/dev/dotfiles";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "blades";
  home.homeDirectory = "/home/blades";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  targets.genericLinux.enable = true;

  imports = [
	"${dots}/personal_gmail.nix"
	"${dots}/personal_git.nix"
	"${dots}/usual_setup.nix"
  ];
}
```

## Theory

Modules are separated so that I can pick and choose based on whether I'm using my work accounts vs personal, or macos vs linux.
