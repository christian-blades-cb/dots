{ pkgs, config, ... }:
{
  users.users.steam-headless = {
    uid = 600;
    isSystemUser = true;
    group = "steam-headless";
  };

  users.groups.steam-headless = {
    gid = 600;
  };

  virtualisation.oci-containers.containers.steam-headless = {
    image = "josh5/steam-headless:latest";

    # lol, --network=host because I can't be bothered to find all the ports anymore
    ports = [

    ];

    hostname = "shrinky";

    extraOptions = [
      "--gpus=all"
      "--security-opt=apparmor=unconfined"
      "--security-opt=seccomp=unconfined"
      "--device=/dev/uinput"
      "--device=/dev/fuse"
      "--device-cgroup-rule=c 13:* rmw"
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_ADMIN"
      "--cap-add=SYS_NICE"
      "--ipc=host"
      "--add-host=steam-headless:127.0.0.1"
      "--add-host=shrinky:127.0.0.1"
      "--network=host"
    ];

    volumes = [
      "/var/lib/steam-headless/home:/home/default:rw"
      "/var/lib/steam-headless/games:/mnt/games:rw"
    ];

    # https://github.com/Steam-Headless/docker-steam-headless/blob/master/docs/compose-files/.env
    environment = {
      NAME = "SteamHeadless";
      TZ = "America/New_York";
      USER_LOCALES = "en_US.UTF-8 UTF-8";
      DISPLAY = ":55";
      MODE = "primary";
      WEB_UI_MODE = "vnc";
      ENABLE_VNC_AUDIO = "true";
      PORT_NOVNC_WEB = "8083";
      ENABLE_STEAM = "true";
      #STEAM_ARGS = "-silent -bigpicture";
      ENABLE_SUNSHINE = "true";
      SUNSHINE_USER = "sunshine";
      SUNSHINE_PASS = "sunshine";
      ENABLE_EVDEV_INPUTS = "true";
      NVIDIA_DRIVER_CAPABILITIES = "all";
      NVIDIA_VISIBLE_DEVICES = "all";

      PUID = "600";
      PGID = "600";
      UMASK = "000";
      USER_PASSWORD = "password";
    };
  };

  # BEWARE: here's where I gave up guessing which ports it was going to listen on
  networking.firewall.enable = false;

  networking.firewall.allowedTCPPorts = [
    7860 5900 8083
    32036 32037 32041
    47984 47989 47990 48010
  ];

  services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # this container expects some host directories to exist for persistence, let's automate that
  systemd.services.steam-headless-init = {
    enable = true;

    wantedBy = [
      "${config.virtualisation.oci-containers.backend}-steam-headless.service"
    ];

    script = ''
      umask 077
      mkdir -p /var/lib/steam-headless/{home,.X11-unix,pulse,games}
      umask 066
    '';

    serviceConfig = {
      User = "steam-headless";
      Group = "steam-headless";
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "steam-headless";
      StateDirectoryMode = "0700";
    };
  };
}
