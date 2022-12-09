{ config, pkgs, ... }:

with pkgs.lib;
let
  # nixGL = let
  #   src = pkgs.fetchFromGitHub {
  #     owner = "guibou";
  #     repo = "nixGL";
  #     rev = "210c6a8a547b4a548b89b08bd46ffedc396bc4f4";
  #     sha256 = "08n0xmqfg63wrzlbffas9nw5jzgkx1answmn8pqyaib3gn7icby2";
  #   };
  # in import "${src}/default.nix" { };
in {
  home.packages = with pkgs.nixgl; [
    nixGLIntel
    # nixGLNvidiaBumblebee
    pkgs.makemkv # registration key: T-2KF3Fsx1NkAkuKtr3o47Fv4Bf4YoFgqnxEPqm9sTPIT1Ya70CTlIcRXbSPPzHIDq7z
  ];
}
