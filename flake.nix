{
  description = "NixOS configuration";

  inputs = {
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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, yabai-src, nixos-hardware, zwave-js, prometheus-mastodon, prom-nut, dashy, nixinate, ... }: rec {
    overlays = {
      nur = inputs.nur.overlay;
      gke-gcloud = inputs.gke-gcloud.overlays.default;
      fenix = inputs.fenix.overlay;
      govuln = inputs.govuln.overlay;
      ghz = inputs.ghz.overlay;
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
      };
    in {
      parkour = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./parkour/configuration.nix
          ./parkour/thinkpad_fan.nix
          ./tailscale.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nixpkgs.overlays = (nixpkgs.lib.attrValues overlays) ++ [ inputs.nixgl.overlay ];
          }
          home-manager.nixosModules.home-manager
          {
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
          ./user-blades.nix
          ./home-assistant/home-assistant.nix
          ./home-assistant/scrypted.nix
          ./peertube/peertube.nix
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
          ./user-blades.nix
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          {
            swapDevices = [ { device = "/var/lib/swapfile"; size = 2 * 1024; } ];
            nix.settings.trusted-users = [ "root" "blades" ];
            security.sudo.wheelNeedsPassword = false;
          }
        ];
      };

      # nix build .#nixosConfigurations.itg-mastodon-oracle-arm.config.system.build.OCIImage
      itg-mastodon-oracle-arm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./oracle-cloud/oci-options.nix
          ./oracle-cloud/oci-image.nix

          ./itg-mastodon/configuration.nix
          ./itg-mastodon/backups.nix
          ./itg-mastodon/oracle_smtp.nix
          ./itg-mastodon/prometheus.nix

          ./user-blades.nix
          ./tailscale.nix

          {
            imports = [ prometheus-mastodon.nixosModule ];
            services.mastodon_prom_exporter = {
              enable = true;
              port = 9020;
              host = "https://interestingtimes.club";
            };
            networking.firewall.allowedTCPPorts = [ 9020 ];
          }

          ({ pkgs, ... }: {
            services.openssh.enable = true;
            services.fail2ban.enable = true;
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;

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

          ./user-blades.nix
          ./tailscale.nix
          {
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;
          }
        ];
      };

      # nix build .#nixosConfigurations.culdesac.config.system.build.VMA
      culdesac = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./culdesac/configuration.nix
          ./peertube/peertube.nix

          ./user-blades.nix
          ({ modulesPath, pkgs, config, ... }: {
            imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
            proxmox.qemuConf.name = config.networking.hostName;
            services.cloud-init.network.enable = true;

            services.openssh.enable = true;
            services.fail2ban.enable = true;
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;
          })
        ];
      };

      # unbound instead of pihole
      adhole-prime = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./adhole/configuration.nix
          ./adhole/unbound-adblocked.nix

          ./user-blades.nix
          ({ modulesPath, config, pkgs, ... }: {
            imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
            networking.hostName = "adhole-prime";
            proxmox.qemuConf.net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1,tag=47"; # tag=47 for dmz
            proxmox.qemuConf.name = config.networking.hostName;
            services.cloud-init.network.enable = true;

            services.openssh.enable = true;
            services.fail2ban.enable = true;
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;
          })
        ];
      };

      adhole = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./adhole/configuration.nix
          ./adhole/unbound-adblocked.nix

          ./user-blades.nix
          ({ modulesPath, config, pkgs, ... }: {
            imports = [ "${modulesPath}/virtualisation/proxmox-image.nix" ];
            networking.hostName = "adhole";
            proxmox.qemuConf.net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1,tag=47"; # tag=47 for dmz
            proxmox.qemuConf.name = config.networking.hostName;
            services.cloud-init.network.enable = true;

            services.openssh.enable = true;
            services.fail2ban.enable = true;
            nix.settings.trusted-users = [ "blades" ];
            security.sudo.wheelNeedsPassword = false;
          })
        ];
      };

      # nix build .#nixosConfigurations.adhole-lxc.config.system.build.tarball
      adhole-lxc = nixpkgs.lib.nixosSystem {
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

      # nix build .#nixosConfigurations.dashboard.config.system.build.VMA
      dashboard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          letMeIn
          defaultSystem
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
              virtualHosts."dashboard.blades" = {
                rejectSSL = true;
                locations."/" = {
                  proxyPass = "http://localhost:4000";
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
    };



    packages.x86_64-linux.nixosConfigurations = self.nixosConfigurations;
  };
}
