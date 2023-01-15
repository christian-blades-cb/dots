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
}
