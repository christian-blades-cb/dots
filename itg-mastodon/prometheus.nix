{ config, pkgs, ... }:
{
  services.prometheus.exporters = {
    systemd.enable = true;
    systemd.openFirewall = true;
    redis.enable = true;
    redis.openFirewall = true;
    postgres.enable = true;
    postgres.openFirewall = true;
    postfix.enable = true;
    postfix.openFirewall = true;
    nginx.enable = true;
    nginx.openFirewall = true;
  };

  services.nginx.statusPage = true;
}
