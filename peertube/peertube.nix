{ config, pkgs, ... }:
let
  domainName = "tube.culdesac.place";
in
{
  # manual step: https://www.npmjs.com/package/peertube-plugin-privacysettings
  services.peertube = {
    enable = true;
    redis.createLocally = true;
    database.createLocally = true;
    smtp.createLocally = true;
    configureNginx = true;
    localDomain = domainName;
    listenWeb = 443;
    enableWebHttps = true;
    settings = {
      tracker.enabled = false;
      followers.instance.enabled = false;
    };

    # settings.listen.hostName = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  services.nginx.virtualHosts."${domainName}" = {
    enableACME = true;
    forceSSL = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "christian.blades+acme@gmail.com";
  };
}
