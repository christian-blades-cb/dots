{ config, pkgs, ... }:
{
  networking.hostName = "elephant";
  time.timeZone = "America/New_York";

  security.acme = {
    acceptTerms = true;
    defaults.email = "christian.blades+acme@gmail.com";
  };

  services.mastodon = {
    enable = true;
    localDomain = "interestingtimes.club"; # Replace with your own domain
    configureNginx = true;
    smtp.fromAddress = "noreply@interestingtimes.club"; # Email address used by Mastodon to send emails, replace with your own
    # extraConfig.SINGLE_USER_MODE = "true";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy = {
    enable = true;
    virtualHosts = {

      # Don't forget to change the host!
      "interestingtimes.club" = {
        extraConfig = ''
          handle_path /system/* {
              file_server * {
                  root /var/lib/mastodon/public-system
              }
          }

          handle /api/v1/streaming/* {
              reverse_proxy  unix//run/mastodon-streaming/streaming.socket
          }

          route * {
              file_server * {
              root ${pkgs.mastodon}/public<your-server-host>
              pass_thru
              }
              reverse_proxy * unix//run/mastodon-web/web.socket
          }

          handle_errors {
              root * ${pkgs.mastodon}/public
              rewrite 500.html
              file_server
          }

          encode gzip

          header /* {
              Strict-Transport-Security "max-age=31536000;"
          }
          header /emoji/* Cache-Control "public, max-age=31536000, immutable"
          header /packs/* Cache-Control "public, max-age=31536000, immutable"
          header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
          header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
        '';
      };
    };
  };

  # Caddy requires file and socket access
  users.users.caddy.extraGroups = [ "mastodon" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
