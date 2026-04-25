{ pkgs, osConfig, ... }:
let
  hostname = osConfig.networking.hostName;
  switchCmd =
    if hostname == "nixos-laptop" then
      "sudo nixos-rebuild switch --flake /home/pleahmacaka/codehere/dotfiles#laptop"
    else if hostname == "nixos-wsl" then
      "sudo nixos-rebuild switch --flake /home/pleahmacaka/codehere/dotfiles#wsl |& nom"
    else
      "echo 'switch: unknown host ${hostname}'";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bright() { brightnessctl set "$1%"; }
    '';

    shellAliases = {
      cls = "clear";
      dev = "nix develop -c zsh";
      switch = switchCmd;
      reload = "pkill -f 'gjs.*ags.js'; hyprctl dispatch exec 'ags run --gtk4'";
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
