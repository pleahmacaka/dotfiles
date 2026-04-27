{ pkgs, osConfig, config, lib, ... }:
let
  flakeAttr = lib.removePrefix "nixos-" osConfig.networking.hostName;
  flakePath = "${config.home.homeDirectory}/codehere/dotfiles";
  switchCmd = "nh os switch ${flakePath} -H ${flakeAttr}";
  testCmd = "nh os test ${flakePath} -H ${flakeAttr}";
  switchCleanCmd = "nh clean all --keep 5 && rm -rf $HOME/.cache/nix && ${switchCmd}";
in
{
  programs.nh = {
    enable = true;
    flake = flakePath;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bright() { brightnessctl set "$1%"; }
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
    '';

    shellAliases = {
      cls = "clear";
      dev = "nix develop -c zsh";
      switch = switchCmd;
      switch-clean = switchCleanCmd;
      try = testCmd;
      reload = "${testCmd} && (pkill -f 'gjs.*ags.js'; hyprctl dispatch exec 'ags run --gtk4')";
      claude = "claude --dangerously-skip-permissions";
      claude-local = "$HOME/.local/bin/claude-local";
      neofetch = "fastfetch";
      notify = "notify-send";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      theme = "robbyrussell";
    };

    plugins = [
      {
        name = "zsh-autoswitch-virtualenv";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-autoswitch-virtualenv";
          rev = "3.7.1";
          sha256 = "sha256-hwg9wDMU2XqJ5FQEwMVVaz0n+xZ8NI82tH9VhLfFRC4=";
        };
        file = "autoswitch_virtualenv.plugin.zsh";
      }
      {
        name = "zsh-bat";
        src = pkgs.fetchFromGitHub {
          owner = "fdellwing";
          repo = "zsh-bat";
          rev = "467337613c1c220c0d01d69b19d2892935f43e9f";
          sha256 = "sha256-TTuYZpev0xJPLgbhK5gWUeGut0h7Gi3b+e00SzFvSGo=";
        };
        file = "zsh-bat.plugin.zsh";
      }
    ];
  };

  programs.starship = {
    enable = true;
  };
}
