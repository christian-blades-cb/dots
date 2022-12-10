{ config, pkgs, ... }:
{
  services.borgbackup.jobs.home = {
    paths = [
      "/home"
    ];
    exclude = [
      # rust cruft
      "**/target"

      # go cruft
      "/home/*/go/bin"
      "/home/*/go/pkg"

      # already backing up my blurays to the same place
      "/home/blades/Videos"
    ];
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/parkour-key";
    };
    environment.BORG_RSH = "ssh -i /home/blades/.ssh/id_rsa -o 'StrictHostKeyChecking accept-new'";
    # This is the magic sauce. Might have to update this if we change how borgbackup is installed on the NAS.
    environment.BORG_REMOTE_PATH = "/usr/local/bin/borg";
    repo = "blades@ds220plus.blades:~/machines/";
    startAt = "daily";
  };
}
