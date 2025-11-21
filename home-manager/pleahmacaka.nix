{ ... }:

{
  imports = [
    ./services
    ./programs
  ];

  home.username = "pleahmacaka";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
