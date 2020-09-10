{ config, pkgs, ...}:
let
  discord = pkgs.callPackage <nixpkgs/pkgs/applications/networking/instant-messengers/discord/base.nix> rec {
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.12";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "0qrzvc8cp8azb1b2wb5i4jh9smjfw5rxiw08bfqm8p3v74ycvwk8";
    };
  };
in {
  home.packages = with pkgs; [
    discord
  ];
}
