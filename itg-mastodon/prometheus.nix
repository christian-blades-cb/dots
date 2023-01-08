{ config, pkgs, ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
    };
    systemd.enable = true;
    systemd.openFirewall = true;
    redis.enable = true;
    redis.openFirewall = true;
    redis.extraFlags = [ "-redis.addr redis://localhost:${toString config.services.redis.servers.mastodon.port}" ];
    postgres.enable = true;
    postgres.openFirewall = true;
    postgres.dataSourceName = let
      cfg = config.services.mastodon.database;
    in
      "user=${config.services.mastodon.user} database=postgres sslmode=disable host=${cfg.host} port=${toString cfg.port}";
    postgres.user = config.services.mastodon.user;
    postfix.enable = true;
    postfix.openFirewall = true;
    nginx.enable = true;
    nginx.openFirewall = true;
  };

  services.nginx.statusPage = true;
}
