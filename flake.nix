{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    wuw.url = "github:PleahMaCaka/wuw";
    wuw.inputs.nixpkgs.follows = "nixpkgs";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      determinate,
      wuw,
      nixos-raspberrypi,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      mkNixosConfig =
        { hostname, modules, extraArgs ? { } }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = extraArgs // { inherit inputs; };
          modules = [
            ./modules/common
            determinate.nixosModules.default
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            { nixpkgs.overlays = [ agenix.overlays.default ]; }
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

      # Pi cluster nodes - built via nixos-raspberrypi's wrapper but pinned
      # to the dotfiles' nixpkgs (26.05) so all hosts share one channel.
      # nixos-raspberrypi still injects its rpi kernel/firmware overlays.
      mkClusterPi =
        { hostname, modules ? [ ] }:
        nixos-raspberrypi.lib.nixosSystem {
          inherit nixpkgs;
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            agenix.nixosModules.default
            { nixpkgs.overlays = [ agenix.overlays.default ]; }
            ./hosts/cluster/common.nix
            ./hosts/cluster/pi/common.nix
            { networking.hostName = hostname; }
          ]
          ++ modules;
        };

      piHostNames = [ "pi-01" "pi-02" "pi-03" "pi-04" "pi-05" ];
      piConfigs = builtins.listToAttrs (map
        (name: {
          name = "cluster-${name}";
          value = mkClusterPi {
            hostname = "cluster-${name}";
          };
        })
        piHostNames);
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
              system.stateVersion = "26.05";
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
        office-desktop = mkNixosConfig {
          hostname = "nixos-office-desktop";
          modules = [
            ./hosts/office-desktop/default.nix
            ./hosts/office-desktop/hardware-configuration.nix
          ];
        };
        desktop = mkNixosConfig {
          hostname = "nixos-desktop";
          modules = [
            ./hosts/desktop/default.nix
            ./hosts/desktop/hardware-configuration.nix
          ];
        };
      }
      // piConfigs;
    };
}
