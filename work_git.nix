{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Christian Blades";
      userEmail = builtins.concatStringsSep "@" [ "blades" "mailchimp.com" ];
      extraConfig = {
        github = {
          user = "christian-blades-cb";
        };
        init.defaultBranch = "main";
        credential.helper = "osxkeychain";
      };
    };
  };
}
