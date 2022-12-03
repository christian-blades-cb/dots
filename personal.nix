{ config, pkgs, ...}:
let
  discord = pkgs.callPackage <nixpkgs/pkgs/applications/networking/instant-messengers/discord/base.nix> rec {
    pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.14";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "1rq490fdl5pinhxk8lkfcfmfq7apj79jzf3m14yql1rc9gpilrf2";
    };
  };
in {
  home.packages = with pkgs; [
    # discord
  ];
}
