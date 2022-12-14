{ config, pkgs, ... }:

let
  dots = "/Users/cblades/dev/dotfiles";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = "cblades";
  # home.homeDirectory = "/Users/blades";

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
    "${dots}/personal.nix"
    "${dots}/parkour.nix"
  ];
}
