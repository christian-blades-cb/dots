{ config, pkgs, ... }:

{
  accounts.email.accounts.gmail = rec {
    address = builtins.concatStringsSep "@" [ "christian.blades" "mailchimp.com" ];
    userName = address;
    flavor = "gmail.com";
    passwordCommand = "${pkgs.pass}/bin/pass work_gmail";
    primary = true;
    realName = "Christian Blades";
  };
}