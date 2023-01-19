{ pkgs, config, ... }:
{

  services.dbus.implementation = "broker";
  hardware.bluetooth.enable = true;

  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    ports = [
      "0.0.0.0:8123:8123/tcp"
    ];
    volumes = [
      "/var/lib/home-assistant/config:/config"
      "/run/dbus:/run/dbus:ro"
    ];
    environment = {
      TZ = "America/New_York";
    };
    extraOptions = [
      "--network=host"
      "--device=/dev/ttyACM1:/dev/ttyACM1" # zigbee dongle
    ];
  };

  systemd.services."home-assistant" = {
    enable = true;
    wantedBy = [ "${config.virtualisation.oci-containers.backend}-home-assistant.service" ];
    script = ''
      mkdir -p /var/lib/home-assistant/config
      chown -R hass:hass /var/lib/home-assistant
    '';

    serviceConfig = {
      # User = "hass";
      # Group = "hass";
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "home-assistant";
      StateDirectoryMode = "0750";
    };
  };

  # https://www.home-assistant.io/integrations/homekit/#firewall
  networking.firewall.allowedTCPPorts = [ 8123 21063 21064 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];


  users.users.hass = {
    isSystemUser = true;
    group = "hass";
    home = "/var/lib/home-assistant";
  };

  users.groups.hass = {};

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "hass" ];
    compression = "zstd";
  };

  services.borgbackup.jobs.home-assistant = {
    paths = [
      config.services.postgresqlBackup.location
      "/var/lib/home-assistant"
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/inchhigh-key";
    };
    environment.BORG_RSG = "ssh -i /root/.ssh/id_rsa -o 'StrictHostKeyChecking accept-new'";
    environment.BORG_REMOTE_PATH = "/usr/local/bin/borg";
    repo = "machine@ds220plus.blades:~/machines/";
    startAt = "daily";
  };
}
