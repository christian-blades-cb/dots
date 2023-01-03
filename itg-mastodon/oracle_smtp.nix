# oracle relay docs: https://docs.oracle.com/en-us/iaas/Content/Email/Reference/postfix.htm#Integrating_Postfix_with_Email_Delivery

{ config, pkgs, ... }:
{
  services.postfix.config = {
    smtp_sasl_auth_enable = "yes";

    # NOTE: Manual step
    # 1. write to sudo chmod 0600 /etc/postfix.blades/sasl_passwd
    #   `smtp.email.us-ashburn-1.oci.oraclecloud.com:587 username:password`
    # 2. sudo chmod 0600 /var/lib/postfix/conf/sasl_passwd
    # 3. sudo postmap /var/lib/postfix/conf/sasl_passwd
    # 4. sudo systemctl start postfix-setup.service
    smtp_sasl_password_maps = "hash:/etc/postfix.blades/sasl_passwd";

    smtp_tls_security_level = "may";
    smtp_sasl_security_options = "";
    smtp_sasl_tls_security_options = "noanonymous";

    # header_size_limit = "4096000";
    # smtp_discard_ehlo_keywords = "size";

    relayhost = "smtp.email.us-ashburn-1.oci.oraclecloud.com:587";
  };
}
