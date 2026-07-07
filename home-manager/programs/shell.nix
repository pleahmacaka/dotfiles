{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}:
let
  flakeAttr = lib.removePrefix "nixos-" osConfig.networking.hostName;
  flakePath = "${config.home.homeDirectory}/Projects/dotfiles";
  # NH_FLAKE is exported by programs.nh.flake below, so nh finds the flake without a prefix.
  switchCmd = "nh os switch -H ${flakeAttr}";
  testCmd = "nh os test -H ${flakeAttr}";
  switchCleanCmd = "nh clean all --keep 5 && rm -rf $HOME/.cache/nix && ${switchCmd}";
  darkWall = ../wallpapers/nix-dark.png;
  lightWall = ../wallpapers/nix-bright.png;

  autoswitchSrc = pkgs.runCommandLocal "zsh-autoswitch-virtualenv-3.7.1" { } ''
    cp -r ${
      pkgs.fetchFromGitHub {
        owner = "MichaelAquilina";
        repo = "zsh-autoswitch-virtualenv";
        rev = "3.7.1";
        sha256 = "sha256-hwg9wDMU2XqJ5FQEwMVVaz0n+xZ8NI82tH9VhLfFRC4=";
      }
    } $out
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

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --strip-cwd-prefix --exclude .git";
  };

  home.packages = [
    pkgs.fd
    pkgs.ripgrep
    pkgs.gh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bright() { brightnessctl set "$1%"; }
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7f849c'

      # User-maintained secrets (not in the repo): export OPENROUTER_API_KEY, etc.
      [[ -f "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

      # Force a widely-supported TERM for ssh; some terminals set a TERM the remote host lacks.
      ssh() { TERM=xterm-256color command ssh "$@"; }

      # bare `nvim` opens cwd; `nvim file` opens the file.
      nvim() { if (($# == 0)); then command nvim .; else command nvim "$@"; fi; }

      # GitHub Copilot CLI (agentic, via `gh copilot -p`): `?? <natural language>`
      # suggest a command, `? <cmd>` explain a command.
      # Install once in a real terminal: `gh copilot` (downloads the CLI).
      copilot_suggest() { gh copilot -- -s -p "Suggest a single shell command for this request, output only the command with no prose: $*"; }
      copilot_explain() { gh copilot -- -s -p "Explain this shell command concisely: $*"; }
      alias -- '??'='noglob copilot_suggest'
      alias -- '?'='noglob copilot_explain'

      # Theme toggle: GTK color-scheme + swaybg wallpaper (hyprland only).
      dark() {
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
        cp -f ~/.config/alacritty/mocha.toml ~/.config/alacritty/theme-active.toml
        pkill -x swaybg 2>/dev/null
        hyprctl dispatch exec "swaybg -m fill -i ${darkWall}"
      }
      light() {
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
        cp -f ~/.config/alacritty/latte.toml ~/.config/alacritty/theme-active.toml
        pkill -x swaybg 2>/dev/null
        hyprctl dispatch exec "swaybg -m fill -i ${lightWall}"
      }

      # Claude Code via OpenRouter (default model z-ai/glm-5.2).
      # First arg containing "/" overrides the model: claude-or sakana/fugu-ultra
      # Key from agenix (/run/agenix/openrouter-api-key); set OPENROUTER_API_KEY to override.
      claude-or() {
        local key="''${OPENROUTER_API_KEY:-}"
        local secret=/run/agenix/openrouter-api-key
        [[ -z "$key" && -r "$secret" ]] && key="$(<"$secret")"
        if [[ -z "$key" ]]; then
          echo "✗ No OpenRouter key: agenix secret $secret missing and OPENROUTER_API_KEY unset." >&2
          echo "  Register it: cd secrets && agenix -e openrouter-api-key.age, then rebuild." >&2
          return 1
        fi
        local model="z-ai/glm-5.2"
        [[ "$1" == */* ]] && { model="$1"; shift; }
        ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
        ANTHROPIC_AUTH_TOKEN="$key" \
        ANTHROPIC_API_KEY="" \
        ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
        ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
        ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
        CLAUDE_CODE_SUBAGENT_MODEL="$model" \
        IS_DEMO=1 \
        claude --dangerously-skip-permissions "$@"
      }

      search() {
        local dir="''${2:-.}" open
        command -v zeditor >/dev/null && open='zeditor {1}:{2}:{3}' || open='nvim +{2} {1}'
        rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' -e "" "$dir" \
          | fzf --ansi --query "''${1:-}" \
              --delimiter : \
              --preview 'bat --color=always --highlight-line {2} {1}' \
              --preview-window 'up,60%,+{2}+3/3' \
              --bind "enter:become($open)"
      }
    '';

    shellAliases = {
      cls = "clear";
      dev = "nix develop -c zsh";
      switch = switchCmd;
      switch-clean = switchCleanCmd;
      try = testCmd;
      reload = "${testCmd} && systemctl --user restart quickshell.service";
      claude = "IS_DEMO=1 claude --dangerously-skip-permissions";
      cc = "claude";
      claude-local = "$HOME/.local/bin/claude-local";
      neofetch = "fastfetch";
      notify = "notify-send";
      somo = "somo -l";
      vi = "nvim";
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
