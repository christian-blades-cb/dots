{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs?rev=30ec7dc6416c7b3d286d047ec905eaf857f712f9";
    darwin.url = "github:lnl7/nix-darwin?rev=4182ad42d5fb5001adb1f61bec3a04fae0eecb95";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    yabai-src = {
      url = "github:koekeishiya/yabai";
      flake = false;
    };
    nur.url = "github:nix-community/NUR";
    gke-gcloud.url = "github:christian-blades-cb/gke-gcloud-auth-plugin-nix";
    gke-gcloud.inputs.nixpkgs.follows = "nixpkgs";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghz.url = "github:christian-blades-cb/ghz-flake";
    ghz.inputs.nixpkgs.follows = "nixpkgs";
    govuln.url = "github:christian-blades-cb/govulncheck-flake";
    govuln.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    zwave-js.url = "github:christian-blades-cb/zwavejs-server-flake";
    zwave-js.inputs.nixpkgs.follows = "nixpkgs";
    prometheus-mastodon = {
      url = "github:christian-blades-cb/mastodon_prom_exporter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prom-nut = {
      url = "github:christian-blades-cb/nut_prom_exporter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dashy = {
      url = "github:christian-blades-cb/dashy-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic = {
      url = "github:zhaofengli/attic";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, yabai-src, nixos-hardware,
                     zwave-js, prometheus-mastodon, prom-nut, dashy, nixinate, agenix,
                     attic, ... }: rec {
    overlays = {
      nur = inputs.nur.overlay;
      gke-gcloud = inputs.gke-gcloud.overlays.default;
      fenix = inputs.fenix.overlay;
      govuln = inputs.govuln.overlay;
      ghz = inputs.ghz.overlay;
      attic = inputs.attic.overlays.default;
    };

    apps = nixinate.nixinate.x86_64-linux self;

    darwinConfigurations = {
      "macos-C02GQ06Z1PG3" = darwin.lib.darwinSystem {
       system = "x86_64-darwin";
        specialArgs = { inherit yabai-src; };
        modules = [
          ./darwin-configuration.nix
          ./work-darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.cblades = import ./work-home.nix;
            nixpkgs.overlays = nixpkgs.lib.attrValues overlays;
            nixpkgs.config.allowUnfree = true;

            users.users.cblades = {
              shell = nixpkgs.fish;
              description = "Christian Blades";
              home = "/Users/cblades";
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };

    nixosConfigurations = let
      letMeIn = {
        imports = [ ./user-blades.nix ];

        services.openssh.enable = true;
        services.fail2ban.enable = true;
        nix.settings.trusted-users = [ "blades" ];
        security.sudo.wheelNeedsPassword = false;
      };
      defaultSystem = {
        time.timeZone = "America/New_York";
        i18n.defaultLocale = "en_US.UTF-8";
        system.stateVersion = "22.11";
        security.pki.certificateFiles = [
          ./step-ca/certs/root_ca.crt
        ];
      };
      internalAcmeDefaults = {
        security.acme.acceptTerms = true;
        security.acme.defaults.email = "christian.blades+acme@gmail.com";
        security.acme.defaults.server = "https://authority.beard.institute/acme/acme/directory";
      };
    in {
      parkour = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./parkour/configuration.nix
          ./parkour/thinkpad_fan.nix
          ./tailscale.nix
          agenix.nixosModules.default
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nixpkgs.overlays = (nixpkgs.lib.attrValues overlays) ++ [ inputs.nixgl.overlay ];
            security.pki.certificateFiles = [
              ./step-ca/certs/root_ca.crt
            ];
            nix.settings.trusted-substituters = [ "https://attic.beard.institute/blades" ];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit agenix; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.blades = (
              { config, pkgs, ... }:
              {
                home.stateVersion = "20.09";

                targets.genericLinux.enable = true;

                imports = [
                  ./usual_setup.nix
                  ./personal.nix
                  ./personal_git.nix
                  ./personal_gmail.nix
                ];
              }
            );
          }
        ];
      };

      inchhigh = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./inchhigh/configuration.nix

          ./inchhigh/ups-client.nix
          # ./inchhigh/hardware-configuration.nix

          ./tailscale.nix
          letMeIn

          ./home-assistant/home-assistant.nix
          ./home-assistant/scrypted.nix
          {
            _module.args.nixinate = {
              host = "inchhigh";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          {
            imports = [ zwave-js.nixosModule ];
            services.zwave-js = {
              enable = true;
              device = "/dev/ttyACM0";
              host = "127.0.0.1";
              port = 3000;
            };
          }
          {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nix.settings.trusted-users = [ "root" "blades" ];
            security.sudo.wheelNeedsPassword = false;
            # nixpkgs.overlays = (nixpkgs.lib.attrValues overlays);
          }
          {
            # ups prometheus monitoring
            imports = [ prom-nut.nixosModule ];

            networking.firewall.allowedTCPPorts = [ 9199 ];

            services.nut_prom_exporter = {
              enable = true;
              server = "ds220plus.blades";
              user = "monuser";
              pass = "secret";
              bind = ":9199";
            };
          }
          {
            services.prometheus.exporters = {
              node = {
                enable = true;
                openFirewall = true;
              };
              systemd = {
                enable = true;
                openFirewall = true;
              };
            };
          }
        ];
      };

      # nix build .#nixosConfigurations.relay.config.system.build.digitalOceanImage
      relay = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./relay/configuration.nix
          ./relay/znc.nix

          ./tailscale.nix
          letMeIn
          ({ modulesPath, ... }: {
            imports = [ "${modulesPath}/virtualisation/digital-ocean-image.nix" ];
          })
          {
            swapDevices = [ { device = "/var/lib/swapfile"; size = 2 * 1024; } ];
            nix.settings.trusted-users = [ "root" "blades" ];
            security.sudo.wheelNeedsPassword = false;
          }
          {
            _module.args.nixinate = {
              host = "relay";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      # nix build .#nixosConfigurations.elephant.config.system.build.OCIImage
      elephant = inputs.nixpkgs-master.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./oracle-cloud/oci-options.nix
          ./oracle-cloud/oci-image.nix

          ./itg-mastodon/configuration.nix
          ./itg-mastodon/backups.nix
          ./itg-mastodon/oracle_smtp.nix
          ./itg-mastodon/prometheus.nix

          letMeIn
          ./tailscale.nix

          {
            _module.args.nixinate = {
              host = "elephant";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          {
            imports = [ prometheus-mastodon.nixosModule ];
            services.mastodon_prom_exporter = {
              enable = true;
              port = 9020;
              host = "https://interestingtimes.club";
            };
            networking.firewall.allowedTCPPorts = [ 9020 ];
            documentation = {
              man.enable = false;
              nixos.enable = false;
              enable = false;
              doc.enable = false;
              info.enable = false;
              dev.enable = false;
            };
          }

          ({ pkgs, ... }: {
            # do the dance to get the right env for `tootctl`
            users.users.blades.packages = let
              tootctlScript = pkgs.writeShellScriptBin "tootctl" ''
                sudo su -s ${pkgs.bash}/bin/bash -l -c "mastodon-env tootctl $*" - mastodon
              '';
            in [ tootctlScript ];
          })
        ];
      };

      # nix build .#nixosConfigurations.metrics.config.system.build.diskstation-image
      # upload this to the hypervisor as an image
      # VM -> create↓ -> from disk image
      # NOTE: Make sure to choose EFI instead of bios
      metrics = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./diskstation-image.nix

          ./metrics/configuration.nix
          ./metrics/prometheus-collector.nix
          ./metrics/grafana.nix

          internalAcmeDefaults
          defaultSystem
          letMeIn

          ./tailscale.nix

          {
            _module.args.nixinate = {
              host = "metrics";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      # nix build .#nixosConfigurations.culdesac.config.system.build.tarball
      culdesac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          ./peertube/peertube.nix
          ({ modulesPath, pkgs, config, ... }: {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
            # imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
            # proxmox.qemuConf.name = config.networking.hostName;
            # services.cloud-init.network.enable = true;
            age.secrets."peertube-secrets" = {
              file = ./secrets/peertube-secrets.age;
              mode = "0770";
              owner = config.services.peertube.user;
              group = config.services.peertube.group;
            };
            services.peertube.secrets.secretsFile = config.age.secrets."peertube-secrets".path;
          })
          {
            _module.args.nixinate = {
              host = "culdesac";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      # nix build .#nixosConfigurations.adhole-lxc.config.system.build.tarball
      adhole-ct-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          ./adhole/unbound-adblocked.nix
          ({modulesPath, ...}: {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "adhole-ct-1";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      adhole-ct-2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          ./adhole/unbound-adblocked.nix
          ({modulesPath, ...}: {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "adhole-ct-2";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      # nix build .#nixosConfigurations.dashboard.config.system.build.VMA
      dashboard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          internalAcmeDefaults
          {
            _module.args.nixinate = {
              host = "dashboard";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          ({ pkgs, config, modulesPath, ... }: {
            imports = [
              "${modulesPath}/virtualisation/proxmox-image.nix"
            ];

            networking.hostName = "dashboard";
            proxmox.qemuConf.name = "dashboard";
            services.cloud-init.network.enable = true;

            services.nginx = {
              enable = true;
              recommendedTlsSettings = true;

              virtualHosts."dashboard.beard.institute" = {
                # serverAliases = [ "dashboard" "dashboard.blades" ];
                enableACME = true;
                addSSL = true;
                locations."/" = {
                  recommendedProxySettings = true;
                  proxyPass = "http://localhost:4000";
                  extraConfig = ''
                    add_header Access-Control-Allow-Origin https://keycloak.beard.institute;
                  '';
                };
              };
            };

            virtualisation.oci-containers.containers.dashy = {
              image = "lissy93/dashy:latest";
              ports = [
                "127.0.0.1:4000:4000/tcp"
              ];
              volumes = [
                "/var/lib/dashy/conf.yml:/app/public/conf.yml"
              ];
              environment = {
                "PORT" = "4000";
              };
            };

            systemd.services.dashy-init = {
              enable = true;

              wantedBy = [ "${config.virtualisation.oci-containers.backend}-dashy.service" ];

              script = ''
                umask 077
                mkdir -p /var/lib/dashy/
                umask 066
                cp ${./dashy/conf.yml} /var/lib/dashy/conf.yml
                chmod 0600 /var/lib/dashy/conf.yml
              '';

              serviceConfig = {
                User = "dashy";
                Group = "dashy";
                Type = "oneshot";
                RemainAfterExit = true;
                StateDirectory = "dashy";
                StateDirectoryMode = "0700";
              };

            };

            networking.firewall.allowedTCPPorts = [ 80 443 ];
          })
        ];
      };

      keycloak = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          {
            age.secrets."keycloak-dbpass".file = ./secrets/keycloak-dbpass.age;
          }
          ({modulesPath, ...}: {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          ({config, ...} : {
            networking.hostName = "keycloak";

            # don't forget to drop a `+` under `Web Origins` for the client config in keycloak, or you're gonna get a lot of CORS errors
            services.keycloak = {
              enable = true;
              database = {
                createLocally = true;
                passwordFile = config.age.secrets."keycloak-dbpass".path;
              };
              sslCertificateKey = "/var/lib/acme/keycloak/key.pem";
              sslCertificate = "/var/lib/acme/keycloak/cert.pem";
              settings = {
                hostname = "keycloak.beard.institute";
                http-port = 8080;
                https-port = 8443;
                proxy = "edge";
              };
            };

            # putting nginx in front of keycloak because it won't serve the new cert when we refresh it from acme
            services.nginx = {
              enable = true;
              recommendedTlsSettings = true;

              # sessions are kinda big
              appendHttpConfig = ''
                proxy_buffer_size   128k;
                proxy_buffers   4 256k;
                proxy_busy_buffers_size   256k;
              '';

              virtualHosts."keycloak.beard.institute" = {
                serverAliases =  [ "keycloak.blades" ];
                addSSL = true;
                useACMEHost = "keycloak";
                locations."/.well-known/acme-challenge" = {
                  root = "/var/lib/acme/acme-challenge";
                  extraConfig = ''
                    auth_basic off;
                  '';
                };
                locations."/" = {
                  proxyPass = "http://localhost:8080";
                  recommendedProxySettings = true;
                };
              };
            };

            services.postgresql.enable = true;

            users.users.keycloak = {
              isSystemUser = true;
              group = "keycloak";
              home = "/var/lib/keycloak";
            };

            users.groups.keycloak = {};

            security.acme.certs.keycloak = {
              domain = "keycloak.beard.institute";
              server = "https://authority.beard.institute/acme/acme/directory";
              group = "nginx";
              webroot = "/var/lib/acme/acme-challenge";
            };

            security.acme.acceptTerms = true;
            security.acme.defaults.email = "christian.blades+acme@gmail.com";

            networking.firewall.allowedTCPPorts = [ 80 443 ];
          })
          {
            _module.args.nixinate = {
              host = "keycloak";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      authority = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          ./step-ca/authority.nix
          ({ config, modulesPath, ... }: {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "authority";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      ingress = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules =[
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          ./traefik/traefik.nix
          ({modulesPath, ...} : {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "ingress";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      paperless = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          ({modulesPath, ...} : {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "paperless";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
        ];
      };

      torrent = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          ({modulesPath, ...} : {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "torrent";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          {
            age.secrets."transmission-credentials".file = ./secrets/transmission-credentials.age;
          }
          ({ config, pkgs, ...}: {
            services.transmission = {
              enable = true;
              openPeerPorts = true;
              openRPCPort = true;
              settings = {
                rpc-bind-address = "0.0.0.0";
                rpc-whitelist = "192.168.*.*,127.0.0.1,::1";
                rpc-authentication-required = true;
              };
              credentialsFile = config.age.secrets."transmission-credentials".path;
            };
            environment.systemPackages = with pkgs; [ ffmpeg sshfs tmux ];
          })
        ];
      };

      minio = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          internalAcmeDefaults
          ({modulesPath, ...} : {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "minio";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          ({config, pkgs, ... }: {
            age.secrets."minio-root-credentials".file = ./secrets/minio-root-credentials.age;

            environment.systemPackages = [ pkgs.jq pkgs.minio-client ];

            services.minio = {
              enable = true;
              rootCredentialsFile = config.age.secrets."minio-root-credentials".path;
            };

            services.nginx = {
              enable = true;
              recommendedTlsSettings = true;
              clientMaxBodySize = "0";
              appendHttpConfig = ''
                proxy_buffering off;
                proxy_request_buffering off;
              '';

              virtualHosts."minio.beard.institute" = {
                # serverAliases = [ "dashboard" "dashboard.blades" ];
                enableACME = true;
                addSSL = true;
                locations."/" = {
                  recommendedProxySettings = true;
                  proxyPass = "http://localhost:9000";
                  extraConfig = ''
                    proxy_http_version 1.1;
                    proxy_set_header Connection "";
                    chunked_transfer_encoding off;
                  '';
                };
                # locations."/minio" = {
                #   recommendedProxySettings = true;
                #   proxyPass = "http://localhost:9001";
                #   proxyWebsockets = true;
                #   extraConfig = ''
                #     proxy_set_header X-NginX-Proxy true;
                #     real_ip_header X-Real-IP;

                #     chunked_transfer_encoding off;
                #   '';
                # };
              };
            };

            networking.firewall.allowedTCPPorts = [ 443 80 9001 ];
          })
        ];
      };

      attic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
          agenix.nixosModules.default
          internalAcmeDefaults
          ({modulesPath, ...} : {
            imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
          })
          {
            _module.args.nixinate = {
              host = "attic";
              sshUser = "blades";
              buildOn = "local"; # valid args are "local" or "remote"
              substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
              hermetic = false;
            };
          }
          attic.nixosModules.atticd
          ({config, ... }: {
            age.secrets."attic-credentials".file = ./secrets/attic-credentials.age;

            networking.firewall.allowedTCPPorts = [ 80 443 ];

            services.nginx = {
              enable = true;
              recommendedTlsSettings = true;
              clientMaxBodySize = "0";
              appendHttpConfig = ''
                proxy_buffering off;
                proxy_request_buffering off;
              '';

              virtualHosts."attic.beard.institute" = {
                enableACME = true;
                addSSL = true;
                locations."/" = {
                  recommendedProxySettings = true;
                  proxyPass = "http://localhost:8080";
                };
              };
            };

            services.atticd = {
              enable = true;
              credentialsFile = config.age.secrets."attic-credentials".path;
              settings = {
                storage = {
                  type = "s3";
                  endpoint = "https://minio.beard.institute";
                  region = "us-east-1";
                  bucket = "attic";
                };
                chunking = {
                  # The minimum NAR size to trigger chunking
                  #
                  # If 0, chunking is disabled entirely for newly-uploaded NARs.
                  # If 1, all NARs are chunked.
                  nar-size-threshold = 64 * 1024; # 64 KiB

                  # The preferred minimum size of a chunk, in bytes
                  min-size = 16 * 1024; # 16 KiB

                  # The preferred average size of a chunk, in bytes
                  avg-size = 64 * 1024; # 64 KiB

                  # The preferred maximum size of a chunk, in bytes
                  max-size = 256 * 1024; # 256 KiB
                };
                listen = "127.0.0.1:8080";
                api-endpoint = "https://attic.beard.institute/";
                allowed-hosts = [ "attic.blades" "attic.beard.institute" "attic" ];
              };
            };
          })
        ];
      };

    };

    # packages.x86_64-linux.nixosConfigurations = self.nixosConfigurations;
  };
}
