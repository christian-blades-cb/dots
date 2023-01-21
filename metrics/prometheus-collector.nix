{ pkgs, config, ... }:

let
  builtinTargets = let
    exporters = [ "systemd" "redis" "postgres" "postfix" "nginx" "node" ];
  in map (x: "elephant:${toString config.services.prometheus.exporters."${x}".port}") exporters;
in
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "elephant";
        static_configs = [
          {
            targets = builtinTargets ++ [ "elephant:9020" ];
          }
        ];
      }
      {
        job_name = "ups";
        metrics_path = "/ups_metrics";
        static_configs = [
          {
            targets = [ "inchhigh.blades:9199" ];
          }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
