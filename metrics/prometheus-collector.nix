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
      {
        job_name = "inchhigh";
        static_configs = [
          {
            targets = map (x: "inchhigh.blades:${toString config.services.prometheus.exporters.${x}.port}") [ "node" "systemd" ];
          }
        ];
      }
      {
        job_name = "ingress";
        static_configs = [
          {
            targets = [ "ingress.beard.institute:8082" ];
          }
        ];
      }
      {
        job_name = "minio";
        bearer_token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoibWluaW9yb290IiwiZXhwIjo0ODMyODYzMjk2fQ.YpiJoYeiujIsDpjjhlK6hIwa2o-sTJgOl7gn6E0kNSgRmf4PKzOHRk_rV1qOgdQxRHcVx8YNF5_8WmSGo87q_g";
        metrics_path = "/minio/v2/metrics/cluster";
        scheme = "http";
        static_configs = [
          { targets = [ "minio.beard.institute:80" ]; }
        ];
      }
      {
        job_name = "culdesac";
        static_configs = [
          { targets = [ "culdesac.beard.institute:9091" ]; }
        ];
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
