{ pkgs, config, ... } : {
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        http = {
          address = ":80";
        };
        https = {
          address = ":443";
        };
      };

      api = { dashboard = true; };

      # plural, dammit, this took so long to debug
      certificatesResolvers = {
        leProd = {
          acme = {
            email = "christian.blades+acme@gmail.com";
            tlsChallenge = {};
            storage = "/var/lib/traefik/acme-leprod.json";
          };
        };
        bladesAuthority = {
          acme = {
            email = "christian.blades+acme@gmail.com";
            tlsChallenge = {};
            storage = "/var/lib/traefik/acme-blades-authority.json";
            caServer = "https://authority.beard.institute/acme/acme/directory";
          };
        };
      };

      entryPoints.metrics.address = ":8082";
      metrics.prometheus = {
        entrypoint = "metrics";
        addRoutersLabels = "true";
      };

      accessLog = {};
    };

    dynamicConfigOptions = import ./dynamic_config.nix;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8082 ];
}
