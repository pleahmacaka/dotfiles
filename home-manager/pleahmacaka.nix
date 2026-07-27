{ lib, osConfig, ... }:

{
  imports = [
    ./services
    ./programs
  ];

  home.username = "pleahmacaka";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # The manual's options.json build warns under flakes.
  manual.manpages.enable = false;
  manual.json.enable = false;

  # WSL is headless, so dconf activation hard-fails there.
  dconf.enable = lib.mkForce (!(osConfig.wsl.enable or false));
}
