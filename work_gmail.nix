{ config, pkgs, ... }:

{
  accounts.email.accounts.gmail = rec {
    address = builtins.concatStringsSep "@" [ "christian.blades" "mailchimp.com" ];
    userName = address;
    flavor = "gmail.com";
    passwordCommand = "${pkgs.pass}/bin/pass work_gmail";
    primary = true;
    realName = "Christian Blades";
    notmuch.enable = true;
    lieer.enable = true;
  };

  programs = {
    lieer.enable = true;
    notmuch = {
      enable = true;
      new.tags = [ "new" ];
      search.excludeTags = [ "trash" "spam" ];
    };
  };
}
