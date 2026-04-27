{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    wuw.url = "github:PleahMaCaka/wuw";
    wuw.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      determinate,
      wuw,
      ...
    }:
    let
      system = "x86_64-linux";
      mkNixosConfig =
        { hostname, modules, extraArgs ? {} }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = extraArgs;
          modules = [
            ./modules/default.nix
            determinate.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hmbak";
              home-manager.users.pleahmacaka = import ./home-manager/pleahmacaka.nix;
            }
          ]
          ++ modules;
        };
    in
    {
      nixosConfigurations = {
        wsl = mkNixosConfig {
          hostname = "nixos-wsl";
          extraArgs = {
            wuw = wuw.defaultPackage.${system};
          };
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
            ./hardware-configuration.nix
          ];
        };
      };
    };
}
