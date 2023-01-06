{ config, pkgs, ... }:
{
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 5000 ];

  services.znc = {
    enable = true;

    openFirewall = false;
    useLegacyConfig = false;
    mutable = false;
    modulePackages = with pkgs.zncModules; [ palaver clientbuffer ];

    config = {
      LoadModule = [ "adminlog" "fail2ban" "webadmin" "palaver" ];

      User.blades = {
        LoadModule = [ "controlpanel" ];
        Admin = true;
        Pass.password = {
          Method = "sha256";
          Hash = "a1fce76537cf4345a9939f951e7e5ce2eb5b753626e47164ce318c42d7daf029";
          Salt = "/.1:_LEj,5Kf,f_vEjO0";
        };
        Network.libera = {
          Server = "irc.libera.chat +6697";
          Chan = { "#scannedinavian" = {}; "#nixos" = {}; };
          Nick = "blades";
          AltNick = "blades___";
          JoinDelay = 1;
          QuitMsg = "see you space cowboy";
          RealName = "Blades";
          LoadModules = [ "keepnick" "simple_away" "sasl" ];
        };
      };
    };
  };
}
