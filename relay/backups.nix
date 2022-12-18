{ config, pkgs, ... }:
{
  services.borgbackup.jobs.relay_home = {
    paths = [
      "/home"
    ];
    exclude = [
    ];
    encryption = {
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /root/borgbackup/machine-key";
      };
    };
    environment.BORG_RSH = "ssh -i /home/blades/.ssh/machine-id_rsa -o 'StrictHostKeyChecking accept-new'";
    environment.BORG_REMOTE_PATH = "/usr/local/bin/borg";
    repo = "machines@ds220plus:~/machines/";
    startAt = "daily";
  };
}
