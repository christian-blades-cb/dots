{ config, pkgs, ... }:

{
  accounts.email.accounts.gmail = rec {
    address = "christian.blades@gmail.com";
    userName = address;
    flavor = "gmail.com";
    passwordCommand = "${pkgs.pass}/bin/pass gmail";
    primary = true;
    realName = "Christian Blades";
  };
}
