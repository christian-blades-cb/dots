{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Christian Blades";
      userEmail = "christian.blades+github@gmail.com";
    };
  };
}
