{ config, pkgs, ... }:
let
  # netskope is a pain, playing whack-a-mole with a bunch of CLI's
  wrappedGcloud = pkgs.symlinkJoin {
    name = "google-cloud-sdk";
    paths = [ pkgs.google-cloud-sdk ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/gcloud \
        --set CLOUDSDK_CORE_CUSTOM_CA_CERTS_FILE '/Library/Application Support/Netskope/STAgent/download/nscacert.pem'
    '';
  };
in {
  programs.go = {
    enable = true;
    goPrivate = [ "*.rsglab.com" ];
  };

  home.packages = with pkgs; [
    # gcloud cli
    wrappedGcloud

    # standard golang tools
    gotools
    mockgen
    golangci-lint
    gke-gcloud-auth-plugin
    govulncheck
    ghz

    # php lsp
    nodePackages.intelephense

    # json lsp
    nodePackages.vscode-json-languageserver-bin

    # js lsp
    nodePackages.typescript-language-server

    # python lsp
    python3Packages.python-lsp-server

    # twirp
    protobuf
    protoc-gen-twirp
    protoc-gen-twirp_php
    buf

    # golang lsp
    gopls
  ];

  # requires a manual step of copying this file to `config_default`
  # gcloud hates immutable configs, so I might retire this thing in favor of the wrapper above
  xdg.configFile."gcloud/configurations/config_example".source =
    let
      iniFormat = pkgs.formats.ini { };
      iniFile = x: iniFormat.generate "config_default" x;
      config.core = {
        account = "christian.blades@mailchimp.com";
        custom_ca_certs_file = "/Library/Application Support/Netskope/STAgent/download/nscacert.pem";
        disable_usage_reporting = true;
      };
    in
      iniFile config;

  # making gcloud the auth provider for GCR
  # equiv of `gcloud auth docker`,
  home.file.".docker/config.json".source =
    let
      jsonFormat = pkgs.formats.json { };
      jsonFile = x: jsonFormat.generate "config.json" x;
      gcloudCredHelpers = hosts: builtins.listToAttrs
        ( builtins.map (x: { name = x; value = "gcloud"; }) hosts);
    in
      jsonFile {
        credHelpers = gcloudCredHelpers [ "gcr.io" "us.gcr.io" "eu.gcr.io" "asia.gcr.io" "staging-k8s.gcr.io" "marketplace.gcr.io" ];
        credsStore = "osxkeychain";
        auths."dockerfactory.rsglab.com" = {};
      };
}
