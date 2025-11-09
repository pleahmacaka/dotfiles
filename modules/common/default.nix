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
    tree
  ];

  security.polkit.enable = true;
}
