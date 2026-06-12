{ pkgs, osConfig, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = [
        "JetBrainsMono Nerd Font"
        "D2Coding"
        "Noto Sans Mono CJK KR"
      ];
      font-size = if osConfig.networking.hostName == "nixos-office-desktop" then 10 else 12;
      background-opacity = 0.98;
      background-blur-radius = 20;
      window-padding-x = 14;
      window-padding-y = 14;
      window-padding-balance = true;
      window-decoration = false;
      shell-integration = "zsh";
      cursor-style = "block";
      copy-on-select = false;
      confirm-close-surface = false;
    };
  };
}
