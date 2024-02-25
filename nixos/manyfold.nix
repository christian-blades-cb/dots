{ pkgs, config, ... }:
{
  users.users.manyfold = {
    isSystemUser = true;
    group = "manyfold";
    uid = 600;
  };

  users.groups.manyfold = {
    gid = 600;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "manyfold";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "manyfold" ];
  };

  networking.firewall.interfaces."podman[0-9]".allowedTCPPorts = [ 5432 ];

  services.redis.servers.manyfold = {
    enable = true;
    port = 6379;
  };

  systemd.services.manyfold-init = {
    enable = true;
    wantedBy = [ "${config.virtualisation.oci-containers.backend}-manyfold.service" ];

    script = ''
      umask 077
      mkdir -p /var/lib/manyfold/{libraries,tmp}
      umask 066
    '';

    serviceConfig = {
      User = "manyfold";
      Group = "manyfold";
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "manyfold";
      StateDirectoryMode = "0700";
    };
  };
  
  virtualisation.oci-containers.containers.manyfold = {
    image = "ghcr.io/manyfold3d/manyfold:latest";

    user = "600:600";
    
    ports = [ "3214:3214" ];

    volumes = [
      "/var/lib/manyfold/libraries:/libraries:rw" # You can either create one "library" in the UI and use `/libraries` as the directory, or sudo mkdir some directories under it (make sure they're 0700 and owned by `manyfold`)
      "/var/lib/manyfold/tmp:/usr/src/app/tmp:rw" # Rails insists on writing to a tmp dir in the root of the app, so here's a workaround for that shit
      "/run/postgresql:/var/lib/postgresql:Z" # unix socket, activerecord doesn't seem to respect `/run/postgresql` so we're mounting it to /var/lib
    ];

    environment = {
      DATABASE_URL = "postgresql://manyfold@%2Fvar%2Flib%2Fpostgresql/manyfold"; 
      SECRET_KEY_BASE = "replace_me_with_agenix"; # TODO: actually do agenix
      REDIS_URL = "redis://host.containers.internal:6379";
      RAILS_LOG_TO_STDOUT = "1";
    };
  };
}
