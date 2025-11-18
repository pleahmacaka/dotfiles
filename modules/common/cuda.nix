{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    prometheus-nvidia-gpu-exporter
  ];

  # https://github.com/nix-community/NixOS-WSL/issues/246
  environment.variables.NIX_LD_LIBRARY_PATH = lib.mkForce "/usr/lib/wsl/lib/";
}
