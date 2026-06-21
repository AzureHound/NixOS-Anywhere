{
  description = "Legion Init flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    {
      nixpkgs,
      disko,
      nixos-hardware,
      ...
    }:
    {
      nixosConfigurations.Legion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          nixos-hardware.nixosModules.raspberry-pi-5

          ./disko.nix
          ./hardware-configuration.nix

          ({ pkgs, ... }: {
            networking = {
              hostName = "Legion";
              networkmanager.enable = true;
            };

            nix = {
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              channel.enable = false;
            };

            services.openssh.enable = true;

            environment.systemPackages = with pkgs; [
              git
              vim

              libraspberrypi
              raspberrypi-eeprom
            ];

            users.users.eden = {
              isNormalUser = true;
              initialPassword = "Snowflake";
              extraGroups = [
                "networkmanager"
                "wheel"
              ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyoX1ZlGb9FFtu9Xw8GE8C+GkwExi03xHZ0LSPnD6zw"
              ];
            };

            system.stateVersion = "26.05";
          })
        ];
      };
    };
}
