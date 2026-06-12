{ lib, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.loader.timeout = 1;

  boot.initrd.systemd.enable = true;

  networking.useDHCP = lib.mkDefault true;

  system.stateVersion = "26.05";
}
