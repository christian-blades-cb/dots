{ pkgs, config, ... }:
{
  # manual step: add virtio1 disk to VM
  fileSystems."/videostore" = {
    device = "/dev/vdb1";
    fsType = "ext4";

    autoResize = true;

    autoFormat = true;
    label = "videostore";
  };

  systemd.services."peertube-videostore-init" = {
    enable = true;
    wantedBy = [ "peertube.service" ];
    after = [ "videostore.mount" ];
    script = ''
      mkdir -p /videostore/peertube
      chown -R ${config.services.peertube.user}:${config.services.peertube.group} /videostore/peertube
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.hostName = "culdesac";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
