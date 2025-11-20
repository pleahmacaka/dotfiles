{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    prometheus-nvidia-gpu-exporter
    (python313.withPackages (ps: [
      python313Packages.torch-bin
      python313Packages.torchvision-bin
    ]))
  ];

  nixpkgs.overlays = [
    (self: super: {
      btop = super.btop.override { cudaSupport = true; };
    })
  ];

  # https://github.com/nix-community/NixOS-WSL/issues/246
  environment.variables.NIX_LD_LIBRARY_PATH = lib.mkForce "/usr/lib/wsl/lib/";
}
