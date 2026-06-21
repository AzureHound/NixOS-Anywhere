{
  description = "Orion Init flake";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations.Orion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko

        ./disko.nix
        ./hardware.nix

        ({ pkgs, ... }: {
          boot.loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot = {
              enable = true;
              consoleMode = "max";
            };
          };

          networking = {
            hostName = "Orion";
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
