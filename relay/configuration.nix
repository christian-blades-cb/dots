{ config, lib, pkgs, ... }:
{
  networking.hostName = "relay";
  time.timeZone = "America/New_York";

  nix.settings.trusted-users = [ "root" "blades" ];

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.blades = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ git ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyUuGT62ZLHBi+S0T1xBEuFwfMxYs/QcMxlTISckNCtaCTTa9iOzsmUSfaAsaJ3PmCPtTe85clI3aHvh6UYMQGdyRKZa+34cnsc/eHB8GA8xcX/kTpUYjn4KwMW1rSNQqU8zrNyA8cWA/E+pfnFojAykZFdqwkXCOocH4EJc0IC/Ak7r9Q+lCafC40xr8TO1cHQq/4gvHTohdEN+OyNbkzZgIffK+ay7FoEZUcePRtOyWEekUGfE+JZ4ktKB+h4OgvczSgRM/O9VOvcoZzlM/F7Z1c5d4a4Rq50bCc2SMEtzX9V5LkTjyXQ0w83vXnLdTMMI2mXs47V6NPVjFFWj5Z version control" ];
  };

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
