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
  colimaStartScript = pkgs.writeShellScriptBin "colima-start" ''
    # trick colima into finishing the setup, we already have the context set ourselves
    DOCKER_CONFIG=$(mktemp -d) colima start
  '';
in {
  programs.go = {
    enable = true;
    goPrivate = [ "*.rsglab.com" "github.intuit.com" ];
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

    # python tooling
    python3Packages.keyring
    python3Packages.keyrings-google-artifactregistry-auth
    # python3Packages.pip

    # php lsp
    nodePackages.intelephense

    # json lsp
    nodePackages.vscode-json-languageserver-bin

    # js lsp
    nodePackages.typescript-language-server

    # python lsp
    python3Packages.python-lsp-server

    # golang lsp
    gopls

    # twirp
    protobuf
    protoc-gen-twirp
    protoc-gen-twirp_php
    buf

    # not docker desktop
    colima
    docker
    docker-credential-helpers
    colimaStartScript
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
      config.auth.disable_ssl_validation = true;
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
        currentContext = "colima";
      };

  # make our own colima docker context
  home.file.".docker/contexts/meta/${builtins.hashString "sha256" "colima"}/meta.json".source =
    let
      jsonFormat = pkgs.formats.json {};
      jsonFile = x: jsonFormat.generate "meta.json" x;
      meta = {
        Name = "colima";
        Metadata.Description = "colima";
        Endpoints.docker = {
          Host = "unix:///Users/cblades/.colima/default/docker.sock";
          SkipTLSVerify = false;
        };
      };
    in
      jsonFile meta;

  #######################################################
  # pip/pypi config                                     #
  #                                                     #
  # NOTE:                                               #
  #   use keyring for credential storage                #
  #     `keyring set artifactory.rsglab.com <USERNAME>` #
  #     provide your artifactory API key                #
  #######################################################

  xdg.configFile."pip/pip.conf".source =
    let
      iniFormat = pkgs.formats.ini { };
      iniFile = x: iniFormat.generate "pip.conf" x;
      conf.global.index-url = "https://artifactory.rsglab.com/artifactory/api/pypi/pypi/simple";
    in
      iniFile conf;

  home.file.".pypirc".source =
    let
      # lists are formatted as multi-line values
      iniFormat = with pkgs.lib; pkgs.formats.ini { listToValue = concatMapStringsSep "\n" (generators.mkValueStringDefault {}); };
      iniFile = x: iniFormat.generate "pip.conf" x;
      conf.distutils.index-servers = [ "rsg" ];
      conf.rsg.repository = "https://artifactory.rsglab.com/artifactory/api/pypi/pypi-local";
    in
      iniFile conf;
}
