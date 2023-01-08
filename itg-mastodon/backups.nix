{ config, pkgs, ... }:
{
  services.borgbackup.jobs.mastodon = {
    paths = [
      "/var/lib/mastodon"
      "/var/backup/postgresql"
    ];
    exclude = [
      "/var/lib/mastodon/public_system/cache"
      "/var/lib/mastodon/public_system/media_attachments"
      "/var/lib/mastodon/public_system/site_uploads"
    ];
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 2;
    };
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /home/blades/.borgbackup/elephant-key";
    };

    # This is a bunch of nonsense with synology. For posterity, I edited /etc/ssh/sshd_config to enable public key auth, then edited /etc/passwd to change the shell of this user.
    environment.BORG_RSH = "ssh -i /home/blades/.borgbackup/backups-id -o 'StrictHostKeyChecking accept-new'";

    # instead added `command="/usr/local/bin/borg serve --restrict-to-path /volume1/homes/machine/borg-elephant` prefix to the proper line in ~/.ssh/authorized_keys"
    # environment.BORG_REMOTE_PATH = "/usr/local/bin/borg";
    repo = "machine@ds220plus:~/borg-elephant/";
    startAt = "daily";
  };
}
