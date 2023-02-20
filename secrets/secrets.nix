let
  blades = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyUuGT62ZLHBi+S0T1xBEuFwfMxYs/QcMxlTISckNCtaCTTa9iOzsmUSfaAsaJ3PmCPtTe85clI3aHvh6UYMQGdyRKZa+34cnsc/eHB8GA8xcX/kTpUYjn4KwMW1rSNQqU8zrNyA8cWA/E+pfnFojAykZFdqwkXCOocH4EJc0IC/Ak7r9Q+lCafC40xr8TO1cHQq/4gvHTohdEN+OyNbkzZgIffK+ay7FoEZUcePRtOyWEekUGfE+JZ4ktKB+h4OgvczSgRM/O9VOvcoZzlM/F7Z1c5d4a4Rq50bCc2SMEtzX9V5LkTjyXQ0w83vXnLdTMMI2mXs47V6NPVjFFWj5Z version control";

  # systems
  keycloak = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/IAOEpBcOw9jSg1mW317RUnQ5hDDcFwDdChcyBFO82";
  authority = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGA5MOaPbajvfLTn+ZZ9YmPDO/gVltZvL27B/iD9s2wF";
in
{
  "keycloak-dbpass.age".publicKeys = [ blades keycloak ];
  
  "step-ca-pass.age".publicKeys = [ blades authority ];
  "step-ca-config.age".publicKeys = [ blades authority ];
  "step-ca.certs.intermediate_ca.crt.age".publicKeys = [ blades authority ];
  "step-ca.secrets.intermediate_ca_key.age".publicKeys = [ blades authority ];
  "step-ca.secrets.ssh_host_ca_key.age".publicKeys = [ blades authority ];
  "step-ca.secrets.ssh_user_ca_key.age".publicKeys = [ blades authority ];
  "step-ca.certs.root_ca.crt.age".publicKeys = [ blades authority ];
}
