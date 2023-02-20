{ pkgs, config, lib, ... }:
let
  cfg = config.services.step-ca;
  templates = pkgs.runCommand "step-ca-templates" { src = ./templates; } ''
    mkdir -p $out/templates
    cp -R $src/* $out/templates/
  '';
in {
  config = lib.mkIf cfg.enable {      
    systemd.services."step-ca-templates-init" = {
      enable = true;
      wantedBy = [ "step-ca.service" ];

      script = ''
        ln -s ${templates}/templates /var/lib/step-ca/templates
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
  
}
