{ config, pkgs, ... }:
{
  services.postfix.config = {
    smtp_sasl_auth_enable = "yes";

    # NOTE: Manual step
    # 1. write to sudo chmod 0600 /var/lib/postfix/conf/sasl_passwd
    #   `[smtp.sendgrid.net]:587 apikey:yourSendGridApiKey`
    # 2. sudo chmod 0600 /var/lib/postfix/conf/sasl_passwd
    # 3. sudo postmap /var/lib/postfix/conf/sasl_passwd
    # 4. sudo systemctl start postfix-setup.service
    smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";

    smtp_sasl_security_options = "noanonymous";
    smtp_sasl_tls_security_options = "noanonymous";
    smtp_tls_security_level = "encrypt";
    header_size_limit = "4096000";
    relayhost = "[smtp.sendgrid.net]:587";
  };
}
