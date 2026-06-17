{ pkgs, osConfig, config, lib, ... }:
let
  flakeAttr = lib.removePrefix "nixos-" osConfig.networking.hostName;
  flakePath = "${config.home.homeDirectory}/codehere/dotfiles";
  nhEnv = "NH_FLAKE=${flakePath}";
  switchCmd = "${nhEnv} nh os switch -H ${flakeAttr}";
  testCmd = "${nhEnv} nh os test -H ${flakeAttr}";
  switchCleanCmd = "${nhEnv} nh clean all --keep 5 && rm -rf $HOME/.cache/nix && ${switchCmd}";

  # The plugin hardcodes /usr/bin/stat, which doesn't exist on NixOS. Point it at coreutils.
  autoswitchSrc = pkgs.runCommandLocal "zsh-autoswitch-virtualenv-3.7.1" { } ''
    cp -r ${pkgs.fetchFromGitHub {
      owner = "MichaelAquilina";
      repo = "zsh-autoswitch-virtualenv";
      rev = "3.7.1";
      sha256 = "sha256-hwg9wDMU2XqJ5FQEwMVVaz0n+xZ8NI82tH9VhLfFRC4=";
    }} $out
    chmod -R +w $out
    substituteInPlace $out/autoswitch_virtualenv.plugin.zsh \
      --replace-fail /usr/bin/stat ${pkgs.coreutils}/bin/stat
  '';
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
      # Default fg=8 (dim gray) shimmers over the translucent/blurred terminal
      # background; a brighter opaque color keeps glyph edges crisp.
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7f849c'
    '';

    shellAliases = {
      cls = "clear";
      dev = "nix develop -c zsh";
      switch = switchCmd;
      switch-clean = switchCleanCmd;
      try = testCmd;
      reload = "${testCmd} && systemctl --user restart quickshell.service";
      claude = "claude --dangerously-skip-permissions";
      cc = "claude --dangerously-skip-permissions";
      claude-local = "$HOME/.local/bin/claude-local";
      neofetch = "fastfetch";
      notify = "notify-send";
      somo = "somo -l";
      # Flip GTK/Qt color-scheme + theme together at runtime (no rebuild);
      # flipping only color-scheme leaves gtk-theme stale = half-themed apps.
      dark = "dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\" && dconf write /org/gnome/desktop/interface/gtk-theme \"'Adwaita-dark'\"";
      white = "dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-light'\" && dconf write /org/gnome/desktop/interface/gtk-theme \"'Adwaita'\"";
      ts = "tailscale";
      mirror = "scrcpy --max-size=1080 --window-title=scrcpy";
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
        src = autoswitchSrc;
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
