{
  pkgs,
  config,
  lib,
  isDark,
  isLaptop,
  isOfficeDesktop,
  ...
}:

let
  tomlFmt = pkgs.formats.toml { };

  mocha = {
    primary = {
      background = "0x11111b";
      foreground = "0xcdd6f4";
      dim_foreground = "0x7f849c";
      bright_foreground = "0xcdd6f4";
    };
    cursor = {
      text = "0x11111b";
      cursor = "0xf5e0dc";
    };
    vi_mode_cursor = {
      text = "0x11111b";
      cursor = "0xb4befe";
    };
    selection = {
      text = "0x11111b";
      background = "0xf5e0dc";
    };
    normal = {
      black = "0x45475a";
      red = "0xf38ba8";
      green = "0xa6e3a1";
      yellow = "0xf9e2af";
      blue = "0x89b4fa";
      magenta = "0xf5c2e7";
      cyan = "0x94e2d5";
      white = "0xbac2de";
    };
    bright = {
      black = "0x585b70";
      red = "0xf38ba8";
      green = "0xa6e3a1";
      yellow = "0xf9e2af";
      blue = "0x89b4fa";
      magenta = "0xf5c2e7";
      cyan = "0x94e2d5";
      white = "0xa6adc8";
    };
  };

  latte = {
    primary = {
      background = "0xeff1f5";
      foreground = "0x4c4f69";
      dim_foreground = "0x8c8fa1";
      bright_foreground = "0x4c4f69";
    };
    cursor = {
      text = "0xeff1f5";
      cursor = "0xdc8a78";
    };
    vi_mode_cursor = {
      text = "0xeff1f5";
      cursor = "0x7287fd";
    };
    selection = {
      text = "0xeff1f5";
      background = "0xdc8a78";
    };
    normal = {
      black = "0x5c5f77";
      red = "0xd20f39";
      green = "0x40a02b";
      yellow = "0xdf8e1d";
      blue = "0x1e66f5";
      magenta = "0xea76cb";
      cyan = "0x179299";
      white = "0xacb0be";
    };
    bright = {
      black = "0x6c6f85";
      red = "0xd20f39";
      green = "0x40a02b";
      yellow = "0xdf8e1d";
      blue = "0x1e66f5";
      magenta = "0xea76cb";
      cyan = "0x179299";
      white = "0xbcc0cc";
    };
  };
in
{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size =
          if isLaptop then
            9
          else if isOfficeDesktop then
            8
          else
            10;
      };

      general.import = [ "${config.home.homeDirectory}/.config/alacritty/theme-active.toml" ];

      window = {
        decorations = "None";
        padding = {
          x = 14;
          y = 14;
        };
        dynamic_padding = true;
      };

      cursor = {
        style.shape = "Beam";
        thickness = 0.2;
      };

      selection.save_to_clipboard = false;
    };
  };

  home.file.".config/alacritty/mocha.toml".source = tomlFmt.generate "mocha.toml" {
    colors = mocha;
    window.opacity = 0.8;
  };

  home.file.".config/alacritty/latte.toml".source = tomlFmt.generate "latte.toml" {
    colors = latte;
    window.opacity = 0.95;
  };

  # Seeded once only; dark/light overwrite it at runtime.
  home.activation.alacrittyTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    d="$HOME/.config/alacritty"
    [ -e "$d/theme-active.toml" ] || $DRY_RUN_CMD cp -L "$d/${
      if isDark then "mocha" else "latte"
    }.toml" "$d/theme-active.toml"
  '';
}
