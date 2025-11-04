{ config, lib, pkgs, ... }:
{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  networking.networkmanager.enable = true;

  virtualisation.vmware.guest.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    wofi
    waybar
    xdg-desktop-portal-hyprland
    alacritty
    foot
  ];

  services.dbus.enable = true;

  users.users.pleahmacaka.extraGroups = [ "video" "audio" ];

  system.stateVersion = "25.05";
}
