# blades' dotfiles

Hello. I manage all my environments with nix and [home-manager](https://github.com/nix-community/home-manager) these days. This means that I can have a consistent dev environment across my machines with little effort, since all of these configs are composable.

## MacOS

### Installation

* Clone this repo
* Install [nix](https://nixos.org/download.html#nix-install-macos).
* [Bootstrap](https://github.com/LnL7/nix-darwin#flakes-experimental) nix-darwin
```bash
nix build --extra-experimental-features "nix-command flakes" build .#darwinConfigurations.<HOSTNAME>.system
./result/sw/bin/darwin-rebuild switch --flake .#
```

### Updating

```bash
git pull
darwin-rebuild switch --flake .#
```

## Linux (not nixos)

### Installation

* Clone this repo
* Install [nix](https://nixos.org/download.html#nix-install-linux)
* [Bootstrap](https://nix-community.github.io/home-manager/index.html#sec-flakes-standalone) home-manager
```bash
nix build .#homeConfigurations.parkour.activationPackage
./result/activate
```

### Updating

```bash
git pull
home-manager switch --flake .#parkour
```

## NixOS

* Clone this repo
* Rebuild
```bash
sudo nixos-rebuild switch --flake .#
```
