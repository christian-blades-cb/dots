{ config, pkgs, lib, ... }:
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
    localDomain = lib.mkDefault domainName;
    listenWeb = lib.mkDefault 443;
    # listenWeb = 443;
    enableWebHttps = true;
    settings = {
      tracker.enabled = false;
      followers.instance.enabled = false;
      open_telemetry.metrics = {
        enabled = true;
        prometheus_exporter = {
          hostname = "0.0.0.0";
          port = 9091;
        };
        tracing.enabled = false;
      };

      # object_storage = {
      #   enabled = true;
      #   endpoint = "minio.beard.institute";

      #   videos = {
      #     bucket_name = "peertube-videos";
      #     prefix = "videos/";
      #   };

      #   streaming_playlists = {
      #     bucket_name = "peertube-videos";
      #     prefix = "streaming-playlists/";
      #   };
      # };
    };

    # settings.listen.hostName = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 443 80 9091 ];

  # services.nginx.virtualHosts."${domainName}" = {
  #   enableACME = true;
  #   forceSSL = true;
  # };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "christian.blades+acme@gmail.com";
  # };
}
