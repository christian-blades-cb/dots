# NOTE: this relies on some manual steps in diskstation
# Under "power" enable UPS Server and add this machine's IP to the allow list
{ config, pks, ... }:
{
  power.ups = {
    enable = true;
    mode = "netclient";
  };

  # comments say not to put this in the nix store because of the secrets
  # this "secret" is the default for diskstation, so I don't care
  environment.etc."nut/upsmon.conf".text = ''
    MONITOR ups@ds220plus.blades 1 monuser secret slave
  '';

  systemd.services.upsd.enable = false;
  systemd.services.upsdrv.enable = false;
}
