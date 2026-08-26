{
  description = "Legion Init flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs =
    {
      nixpkgs,
      disko,
      nixos-raspberrypi,
      ...
    }@inputs:
    {
      nixosConfigurations.Legion = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          nixos-raspberrypi = inputs.nixos-raspberrypi;
        };
        modules = [
          disko.nixosModules.disko
          nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          nixos-raspberrypi.nixosModules.trusted-nix-caches
          nixos-raspberrypi.lib.inject-overlays

          ./disko.nix
          ./hardware.nix

          ({ pkgs, ... }: {
            boot.loader.raspberry-pi.bootloader = "kernel";

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
