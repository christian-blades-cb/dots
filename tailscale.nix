{ pkgs, config, ... }:
{
  services.tailscale = {
    enable = true;
    permitCertUid = "christian.blades@gmail.com";
  };
  networking.firewall.checkReversePath = "loose";
}
