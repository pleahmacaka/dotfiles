{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    wuw.url = "github:PleahMaCaka/wuw";
    wuw.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    claude-science.url = "github:pleahmacaka/claude-science-nix";
    claude-science.inputs.nixpkgs.follows = "nixpkgs";

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
      claude-science,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      forDevSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];

      mkNixosConfig =
        {
          hostname,
          modules,
          extraArgs ? { },
        }:
        let
          traits = {
            isDark = hostname == "nixos-desktop";
            isLaptop = hostname == "nixos-laptop";
            isOfficeDesktop = hostname == "nixos-office-desktop";
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = extraArgs // { inherit inputs; } // traits;
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
              home-manager.extraSpecialArgs = traits;
              home-manager.users.pleahmacaka = import ./home-manager/pleahmacaka.nix;
            }
          ]
          ++ modules;
        };

      mkClusterPi =
        {
          hostname,
          extraModules ? [ ],
        }:
        let
          nodeFile = ./hosts/cluster/pi + "/${nixpkgs.lib.removePrefix "cluster-" hostname}.nix";
        in
        nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            agenix.nixosModules.default
            { nixpkgs.overlays = [ agenix.overlays.default ]; }
            ./hosts/cluster/common.nix
            ./hosts/cluster/pi/common.nix
            { networking.hostName = hostname; }
          ]
          ++ nixpkgs.lib.optional (builtins.pathExists nodeFile) nodeFile
          ++ extraModules;
        };

      piHostNames = [
        "pi-01"
        "pi-02"
        "pi-03"
        "pi-04"
        "pi-05"
      ];
      piConfigs = builtins.listToAttrs (
        map (name: {
          name = "cluster-${name}";
          value = mkClusterPi {
            hostname = "cluster-${name}";
          };
        }) piHostNames
      );

      piImages = builtins.listToAttrs (
        map (name: {
          name = "image-${name}";
          value =
            (mkClusterPi {
              hostname = "cluster-${name}";

              extraModules = [
                nixos-raspberrypi.nixosModules.sd-image
                ./hosts/cluster/bootstrap.nix
              ];
            }).config.system.build.sdImage;
        }) piHostNames
      );
    in
    {
      nixosConfigurations = {
        wsl = mkNixosConfig {
          hostname = "nixos-wsl";
          extraArgs = {
            wuw = wuw.defaultPackage.${system};
            claude-science = claude-science.packages.${system}.default;
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
            ./hosts/_shared/workstation.nix
            ./hosts/office-desktop/hardware-configuration.nix
          ];
        };
        desktop = mkNixosConfig {
          hostname = "nixos-desktop";
          modules = [
            ./hosts/_shared/workstation.nix
            ./hosts/desktop/hardware-configuration.nix
          ];
        };
      }
      // piConfigs;

      packages.aarch64-linux = piImages;

      devShells = forDevSystems (s: {
        default = nixpkgs.legacyPackages.${s}.mkShellNoCC {
          packages = with nixpkgs.legacyPackages.${s}; [
            just
            nixfmt
            nixos-rebuild
            agenix.packages.${s}.default
          ];
        };
      });

      formatter = forDevSystems (s: nixpkgs.legacyPackages.${s}.nixfmt);
    };
}
