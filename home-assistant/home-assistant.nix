{ pkgs, config, ... }:
{

  services.dbus.implementation = "broker";
  hardware.bluetooth.enable = true;

  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:2023.12.3";
    ports = [
      "0.0.0.0:8123:8123/tcp"
      "0.0.0.0:5683:5683/udp"
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
      # "--device=/dev/zwave:/dev/ttyACM0"
      "--device=/dev/zigbee:/dev/ttyACM0"
    ];
  };

  services.udev.extraRules = ''
    # Conbee II 1cf1:0030 
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1cf1", ATTRS{idProduct}=="0030", SYMLINK+="zigbee"
    # Z-stick gen5 0658:0200
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", SYMLINK+="zwave"
  '';

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
  networking.firewall.allowedUDPPorts = [ 5353 5683 ];


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
      ensureDBOwnership = true;
      # ensurePermissions = {
      #   "DATABASE hass" = "ALL PRIVILEGES";
      # };
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
