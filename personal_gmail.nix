{ config, pkgs, ... }:

{
  accounts.email.accounts.gmail = rec {
    address = builtins.concatStringsSep "@" [ "christian.blades" "gmail.com" ];
    userName = address;
    flavor = "gmail.com";
    passwordCommand = "${pkgs.pass}/bin/pass gmail";
    primary = true;
    realName = "Christian Blades";
    notmuch = {
      enable = true;
    };
    lieer = {
      enable = true;
      sync = {
        enable = false;
        frequency = "*:0/15";
      };
    };
  };

  programs = {
    lieer = {
      enable = true;
    };
    notmuch = {
      enable = true;
      new.tags = [ "new" ];
      search.excludeTags = [ "trash" "spam" ];
    };
  };

  # services = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  #   lieer.enable = true;
  # };
}
