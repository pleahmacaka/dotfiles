{ pkgs, ... }:

{
  imports = [
    ./cuda.nix
    ./development.nix
    ./shell.nix
    ./users.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Seoul";

  programs.nix-ld.enable = true;
  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gh
    neovim
    btop
    tree
    nil
    nixd
  ];

  security.polkit.enable = true;
}
