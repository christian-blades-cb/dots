{ pkgs, config, lib, ... }:
# https://www.reddit.com/r/NixOS/comments/innzkw/pihole_style_adblock_with_nix_and_unbound/

let
  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "unbound-zones-adblock";

    src = (pkgs.fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.13.11";
      sha256 = "sha256-4UXzwq/vsOlcmZYOeeEDEm2hX93q4pBA8axA+S1eUZ8=";
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
        private-domain = [ "blades" "dmz" "iot" "beard.institute" "culdesac.place" ];
        local-zone = [
          "beard.institute. transparent"
        ];
        local-data = [
          ''"authority.beard.institute. IN A 192.168.129.216"''
          ''"keycloak.beard.institute. IN A 192.168.129.110"''
          ''"proxmox-prime.beard.institute. IN A 192.168.0.202"''
          ''"dashboard.beard.institute. IN A 192.168.0.26"''
          ''"inchhigh.beard.institute. IN A 192.168.0.42"''
          ''"home-assistant.beard.institute. IN CNAME inchhigh.beard.institute."''
          ''"minio.beard.institute. IN A 192.168.0.135"''
          ''"attic.beard.institute. IN A 192.168.0.120"''
          ''"books.beard.institute. IN A 192.168.0.9"''
        ];
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
