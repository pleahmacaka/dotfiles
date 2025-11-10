{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      mkNixosConfig =
        { hostname, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/common/default.nix
            home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ]
          ++ modules;
        };
    in
    {
      nixosConfigurations = {
        wsl = mkNixosConfig {
          hostname = "nixos-wsl";
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl/default.nix
            {
              system.stateVersion = "25.05";
              wsl.enable = true;
            }
          ];
        };

        laptop = mkNixosConfig {
          hostname = "nixos-laptop";
          modules = [
            ./hosts/laptop/default.nix
          ];
        };

        raspberry-pi = mkNixosConfig {
          hostname = "nixos-rpi";
          modules = [
            ./hosts/rpi/default.nix
          ];
        };
      };
    };
}
