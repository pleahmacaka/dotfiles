{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        source = "nixos_small";
        padding = {
          left = 2;
          right = 4;
        };
      };

      display = {
        separator = "  ";
      };

      modules = [
        "break"
        {
          type = "title";
          key = "╭─ ";
          keyColor = "cyan";
        }
        "break"
        {
          type = "os";
          key = "│ 󰣚";
          keyColor = "cyan";
        }
        {
          type = "kernel";
          key = "│ ";
          keyColor = "cyan";
        }
        {
          type = "packages";
          format = "{} (nix)";
          key = "│ 󰏖";
          keyColor = "cyan";
        }
        {
          type = "shell";
          key = "│ ";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = "│ ";
          keyColor = "cyan";
        }
        {
          type = "wm";
          key = "│ 󰖲";
          keyColor = "cyan";
        }
        "break"
        {
          type = "cpu";
          key = "│ ";
          keyColor = "magenta";
        }
        {
          type = "gpu";
          key = "│ 󰢮";
          keyColor = "magenta";
        }
        {
          type = "memory";
          key = "│ ";
          keyColor = "magenta";
        }
        {
          type = "disk";
          key = "│ ";
          keyColor = "magenta";
        }
        "break"
        {
          type = "colors";
          key = "╰─ ";
          keyColor = "cyan";
          symbol = "circle";
        }
      ];
    };
  };
}
