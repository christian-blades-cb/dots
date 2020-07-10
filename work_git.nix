{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Christian Blades";
      userEmail = builtins.concatStringsSep "@" [ "blades" "mailchimp.com" ];
    };
  };
}
