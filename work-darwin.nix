{ config, pkgs, ... }:

{
  homebrew = {
    enable = true;
    extraConfig = ''
      tap "rsg/tap", "https://git.rsglab.com/rsg/homebrew-tap.git"
      brew "rsg/tap/devtool"
      brew "rsg/tap/pando-cli"
    '';
  };
}
