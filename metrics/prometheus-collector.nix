{ pkgs, config, ... }:
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "elephant";
        static_configs = [
          {
            targets = let
              exporters = [ "systemd" "redis" "postgres" "postfix" "nginx" "node" ];
            in map (x: "elephant:${toString config.services.prometheus.exporters."${x}".port}") exporters;
          }
        ];
      }
    ];
  };
}
