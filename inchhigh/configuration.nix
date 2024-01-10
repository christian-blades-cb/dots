{ config, pkgs, lib, modulesPath, ...}:
{
  imports = [
    # NOTE: enable me after running nixos-generate-config
    # ./hardware-configuration.nix
  ];

  networking.hostName = "inchhigh";
  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/62131
  # TODO: this just killed network altogether.
  #       Based on looking at proxmox, I think I need to not assign an IP to either the bridge or the physical interface.
  #       Probably the physical.
  #
  # networking = {
  #   bridges.br0.interfaces = [ "enp3s0" ];
  # };

  # environment.etc."cni/net.d/500-bladesnet.conflist".source = ./bladesnet-cni.conflist;
  # environment.etc."cni/net.d/501-dmznet.conflist".source = ./dmznet-cni.conflist;

  # https://myme.no/posts/2021-11-25-nixos-home-assistant.html

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      priority = 1;
    }
  ];

  zramSwap.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" ];
    # loader.grub.device = lib.mkDefault "/dev/vda";
    loader.timeout = lib.mkDefault 0;
    initrd.availableKernelModules = [ "uas" ];
  };

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  system.build.rawImage = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = "auto";
    format = "raw";
  };

  system.stateVersion = "22.11";

  # virtualisation.oci-containers.containers.echo-server = {
  #   image = "ealen/echo-server:latest";
  #   environment = {
  #     TZ = "America/New_York";
  #   };
  #   extraOptions = [
  #     "--network bladesnet"
  #   ];
  # };
}
