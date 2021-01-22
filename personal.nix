{ config, pkgs, ...}:
let
  discord = pkgs.callPackage <nixpkgs/pkgs/applications/networking/instant-messengers/discord/base.nix> rec {
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.13";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "0d5z6cbj9dg3hjw84pyg75f8dwdvi2mqxb9ic8dfqzk064ssiv7y";
    };
  };
in {
  home.packages = with pkgs; [
    discord
  ];
}
