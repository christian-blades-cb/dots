{ config, pkgs, ... }:

{
  accounts.email.accounts.gmail = rec {
    address = builtins.concatStringsSep "@" [ "christian.blades" "gmail.com" ];
    userName = address;
    flavor = "gmail.com";
    passwordCommand = "${pkgs.pass}/bin/pass gmail";
    primary = true;
    realName = "Christian Blades";
  };
}