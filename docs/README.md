# Installation

```sh
nixos-generate-config --dir ~/NixOS-Anywhere
```

```sh
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount ./disko.nix
```

**fileSystems = { };**

```sh
sudo nixos-install --flake .#Notebook
```

```sh
sudo rm -rf /mnt/root/.nix-defexpr/channels
sudo rm -rf /mnt/nix/var/nix/profiles/per-user/root/channels
```
