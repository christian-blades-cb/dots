{ pkgs, config, lib, ... }:
# https://www.reddit.com/r/NixOS/comments/innzkw/pihole_style_adblock_with_nix_and_unbound/

let
  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "unbound-zones-adblock";

    src = (pkgs.fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.12.5";
      sha256 = "sha256-j9akjKqOWo/DiWAH9KgM8ZOahW9Ln6qz2yw/lMgiUwU=";
    } + "/hosts");

    phases = [ "installPhase" ];

    installPhase = ''
      ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, ".\" static"}' $src | tr '[:upper:]' '[:lower:]' | sort -u >  $out
    '';
  };
in {
  systemd.suppressedSystemUnits = [ "systemd-resolved.service" ];

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];

  services.unbound = {

    enable = true;
    resolveLocalQueries = false;

    settings = {
      server = {
        interface = [ "0.0.0.0" ];
        access-control = [
          "127.0.0.0/24 allow"
          "192.168.0.0/17 allow"
          "192.168.129.0/24 allow"
        ];
        domain-insecure = [ "blades" "dmz" "iot" ];
      };
      forward-zone = [
        {
          name = "blades.";
          forward-addr = [ "192.168.129.1" ];
          forward-first = "no";
        }
        {
          name = "dmz.";
          forward-addr = [ "192.168.129.1" ];
        }
        {
          name = "iot.";
          forward-addr = [ "192.168.129.1" ];
        }
        # {
        #   name = ".";
        #   forward-addr = [ "1.1.1.1@853#cloudflare-dns.com" "1.0.0.1@853#cloudflare-dns.com" ];
        # }
      ];
      server.so-reuseport = "yes";
      server.include = [ "${adblockLocalZones}" ];
    };

  };

}
