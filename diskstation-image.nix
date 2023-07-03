{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/profiles/headless.nix"
  ];

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];

    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub = {
      device = "nodev";
      splashImage = null;
      efiInstallAsRemovable = true;
      efiSupport = true;
    };
    # boot.loader.timeout = 0;

    services.qemuGuest.enable = true;
    services.openssh.enable = true;

    system.build.diskstation-image = import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;
      diskSize = 8192;
      partitionTableType = "efi";
      format = "qcow2";
    };
  };
}
