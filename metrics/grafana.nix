{ config, pkgs, ... }:
{
  # grafana configuration
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "metrics.beard.institute";
      root_url = "https://metrics.beard.institute";
      # http_port = 2342;
      http_addr = "127.0.0.1";
    };
    settings."auth.generic_oauth" = {
      enabled = "true";
      scopes = "openid email profile";
      name = "Keycloak";
      client_id = "grafana";
      auth_url =  "https://keycloak.beard.institute/realms/blades-network/protocol/openid-connect/auth";
      token_url = "https://keycloak.beard.institute/realms/blades-network/protocol/openid-connect/token";
      api_url = "https://keycloak.beard.institute/realms/blades-network/protocol/openid-connect/userinfo";
      use_pkce = "true";
      allow_sign_up = "true";
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    enableACME = true;
    addSSL = true;

    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
    };
  };

  services.nginx.recommendedTlsSettings = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
