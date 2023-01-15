# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # remote nixos-rebuild without root
  nix.settings.trusted-users = [ "root" "blades" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "inchhigh"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # wireguard
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp3s0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall.allowedUDPPorts = [ 51820 4001 ];

  networking.wireguard.interfaces = {
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that Wireguard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp3s0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp3s0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/etc/wireguard.private";

      # generate one if it doesn't already exist
      generatePrivateKeyFile = true;

      peers = [
        # List of allowed peers.
        { # parkour
          # Public key of the peer (not a file path).
          publicKey = "OmaJPYH+eopq9/emj3HSIp9ii2m5r0RHuRR8aoec2n0=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.2/32" ];
        }
        { # christian's phone
          publicKey = "GNifz2Nk9bJtomDuj6lpn8yjtsmRIBzx0h4PhY7k92o=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        { # christian's iphone
          publicKey = "Lquc1mahttAGgZrv1Mn2AZHnMjgiF28JhtRNVq/OWQg=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
      ];
    };
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.blades = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyUuGT62ZLHBi+S0T1xBEuFwfMxYs/QcMxlTISckNCtaCTTa9iOzsmUSfaAsaJ3PmCPtTe85clI3aHvh6UYMQGdyRKZa+34cnsc/eHB8GA8xcX/kTpUYjn4KwMW1rSNQqU8zrNyA8cWA/E+pfnFojAykZFdqwkXCOocH4EJc0IC/Ak7r9Q+lCafC40xr8TO1cHQq/4gvHTohdEN+OyNbkzZgIffK+ay7FoEZUcePRtOyWEekUGfE+JZ4ktKB+h4OgvczSgRM/O9VOvcoZzlM/F7Z1c5d4a4Rq50bCc2SMEtzX9V5LkTjyXQ0w83vXnLdTMMI2mXs47V6NPVjFFWj5Z version control" ];
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = let
      dockerDaemonConfig = pkgs.writeText "daemon.json" (builtins.toJSON {
        data-root = "/opt/docker/var/docker";
      });
    in "--config-file=${dockerDaemonConfig}";
    autoPrune.enable = true;
    enableOnBoot = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];
  #   wget vim
  #   firefox
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi.enable = true;

  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole:2022.11.2";
      ports = [
        "0.0.0.0:53:53/tcp"
        "0.0.0.0:53:53/udp"
        "0.0.0.0:67:67/udp"
        "0.0.0.0:8080:80/tcp"
      ];
      environment = {
        TZ = "America/New_York";
      };
      volumes = [
        "/opt/pihole/etc/pihole/:/etc/pihole/"
        "/opt/pihole/etc/dnsmasq.d/:/etc/dnsmasq.d/"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
