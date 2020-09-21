{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Christian Blades";
      userEmail = builtins.concatStringsSep "@" [ "christian.blades+github" "gmail.com" ];
      extraConfig = {
        github.user = "christian-blades-cb";
      };
    };
  };
}
