{ pkgs, config, modulesPath, ... }: {
  imports = [ ./templates.nix ];

  age.secrets."step-ca-pass".file = ../secrets/step-ca-pass.age;
  age.secrets."step-ca.certs.intermediate_ca.crt" = {
    file = ../secrets/step-ca.certs.intermediate_ca.crt.age;
    owner = "step-ca";
    group = "step-ca";
    mode = "400";
    path = "/var/lib/step-ca/certs/intermediate_ca.crt";
  };
  age.secrets."step-ca.secrets.intermediate_ca_key" = {
    file = ../secrets/step-ca.secrets.intermediate_ca_key.age;
    owner = "step-ca";
    group = "step-ca";
    mode = "400";
    path = "/var/lib/step-ca/secrets/intermediate_ca_key";
  };
  age.secrets."step-ca.secrets.ssh_host_ca_key" = {
    file = ../secrets/step-ca.secrets.ssh_host_ca_key.age;
    owner = "step-ca";
    group = "step-ca";
    mode = "400";
    path = "/var/lib/step-ca/secrets/ssh_host_ca_key";
  };
  age.secrets."step-ca.secrets.ssh_user_ca_key" = {
    file = ../secrets/step-ca.secrets.ssh_user_ca_key.age;
    owner = "step-ca";
    group = "step-ca";
    mode = "400";
    path = "/var/lib/step-ca/secrets/ssh_user_ca_key";
  };
  age.secrets."step-ca.certs.root_ca.crt" = {
    file = ../secrets/step-ca.certs.root_ca.crt.age;
    owner = "step-ca";
    group = "step-ca";
    mode = "400";
    path = "/var/lib/step-ca/certs/root_ca.crt";
  };

    services.step-ca = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./ca.json);
    intermediatePasswordFile = config.age.secrets."step-ca-pass".path;
    openFirewall = true;
    address = "0.0.0.0";
    port = 443;              
  };
}
