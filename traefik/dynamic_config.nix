{
  http = {
    routers = {
      tube = {
        rule = "Host(`tube.culdesac.place`)";
        service = "culdesac";
        tls = {
          certResolver = "leProd";
        };
      };

      traefik-console = {
        rule = "Host(`ingress.beard.institute`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
        service = "api@internal";
        middlewares = [ "console-auth" "local-network-only" ];

        tls = {
          certResolver = "bladesAuthority";
        };
      };
    };

    middlewares = {
      console-auth = {
        basicAuth = {
          users = [
            "blades:$apr1$/ohRr1DS$fktUn7l0DZETrCWt8Zbja/"
          ];
        };
      };

      local-network-only = {
        ipWhitelist = {
          sourceRange = [ "192.168.0.0/16" "127.0.0.0/32" ];
        };
      };
    };

    services = {
      culdesac = {
        loadBalancer = {
          servers = [
            { url = "http://culdesac.beard.institute"; }
          ];
        };
      };
    };
  };
}
