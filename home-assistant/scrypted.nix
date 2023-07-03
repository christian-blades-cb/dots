{ pkgs, config, lib, ... }:
{
  virtualisation.oci-containers.containers.scrypted = {
    image = "koush/scrypted:18-bullseye-full-v0.6.10";
    volumes = [
      "/var/lib/scrypted:/server/volume"
    ];
    environment = {
      TZ = "America/New_York";
    };
    extraOptions = [
      "--network=host"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 10443 11080 36248 48937 ];

  systemd.services."scrypted" = {
    enable = true;
    wantedBy = [ "${config.virtualisation.oci-containers.backend}-scrypted.service" ];
    script = ''
      true
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "scrypted";
      StateDirectoryMode = "0750";
    };
  };

  # services.borgbackup.jobs.scrypted = {
  #   paths = [
  #     "/var/lib/scrypted"
  #   ];
  #   encryption = {
  #     mode = "repokey-blake2";
  #     passCommand = "cat /root/borgbackup/inchhigh-key";
  #   };
  #   environment.BORG_RSG = "ssh -i /root/.ssh/id_rsa -o 'StrictHostKeyChecking accept-new'";
  #   environment.BORG_REMOTE_PATH = "/usr/local/bin/borg";
  #   repo = "machine@ds220plus.blades:~/machines/";
  #   startAt = "daily";
  # };
}
