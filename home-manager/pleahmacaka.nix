{ lib, osConfig, ... }:

{
  imports = [
    ./services
    ./programs
  ];

  home.username = "pleahmacaka";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Skip the HM manual; its options.json build emits a context warning under flakes.
  manual.manpages.enable = false;
  manual.json.enable = false;

  # WSL is headless: no session dconf service, so the dconf activation the
  # desktop theme config triggers hard-fails. Skip it there.
  dconf.enable = lib.mkForce (!(osConfig.wsl.enable or false));
}
