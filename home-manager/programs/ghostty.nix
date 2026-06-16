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
      font-size =
        if osConfig.networking.hostName == "nixos-laptop" then 9
        else if osConfig.networking.hostName == "nixos-office-desktop" then 8
        else 10;
      theme = "Catppuccin Mocha";
      # Force a dark glass tint so transparency reads moody, not washed-out.
      background = "11111b";
      # Higher opacity + lower blur keeps a glass tint without the translucent
      # backdrop shimmering through anti-aliased glyph edges (jagged dim text).
      background-opacity = 0.8;
      background-blur-radius = 20;
      window-padding-x = 14;
      window-padding-y = 14;
      window-padding-balance = true;
      window-decoration = false;
      shell-integration = "zsh";
      cursor-style = "bar";
      adjust-cursor-thickness = "2";
      copy-on-select = false;
      confirm-close-surface = false;
    };
  };
}
