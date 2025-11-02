{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Asia/Seoul";

  networking.hostName = "nixos";

  programs.nix-ld.enable = true;
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gh
    neovim
    btop
  ];

  security.polkit.enable = true;

  users.users.pleahmacaka = {
    isNormalUser = true;
    group = "pleahmacaka";
    extraGroups = [ "wheel" ];
    password = "nixos";
  };

  users.groups.pleahmacaka = {};

  system.stateVersion = "25.05";
}
