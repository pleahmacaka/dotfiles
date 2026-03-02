{ lib, pkgs, ... }:

{
  imports = [ ../../modules/wuw.nix ];

  # assign true in flake.nix
  wsl.enable = lib.mkDefault false;
  wsl.defaultUser = "pleahmacaka";

  networking.networkmanager.enable = false;

  services.dbus.enable = true;

  programs.zsh = {
    shellAliases = {
      switch = "sudo nixos-rebuild switch --flake .#wsl |& nom";
    };
  };

  environment.systemPackages = with pkgs; [
    wslu # handle xdg-open stuff
    usbutils
    kmod
  ];
}
