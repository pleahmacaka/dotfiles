{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Asia/Seoul";

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
}
