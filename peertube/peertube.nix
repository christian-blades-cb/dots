{ config, pkgs, ... }:
{
  services.peertube = {
    enable = true;
    redis.createLocally = true;
    database.createLocally = true;
    smtp.createLocally = true;
    configureNginx = true;
    localDomain = "inchhigh.blades";
    listenWeb = 80;
    # settings.listen.hostName = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
