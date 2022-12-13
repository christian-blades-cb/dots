{ config, pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    discord
    # makemkv # registration key: T-2KF3Fsx1NkAkuKtr3o47Fv4Bf4YoFgqnxEPqm9sTPIT1Ya70CTlIcRXbSPPzHIDq7z
    _1password
    _1password-gui
  ];

  services.caffeine.enable = true;

  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      onepassword-password-manager
    ];
    profiles.blades =
      {
        id = 0;
        bookmarks = [
          {
            name = "Rust stdlib docs";
            url = "https://doc.rust-lang.org/stable/std/index.html";
          }
          {
            name = "lib.rs";
            url = "https://lib.rs";
          }
          {
            name = "nix";
            bookmarks = [
              {
                name = "NUR packages";
                url = "https://nur.nix-community.org/";
              }
            ];
          }
        ];
      };

  };
}
