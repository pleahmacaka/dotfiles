{ pkgs, ... }:

{
  imports = [
    # ./cuda.nix
    ./development.nix
    ./users.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Seoul";

  programs.nix-ld.enable = true;
  programs.neovim.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      diff-sys = "nvd diff /run/current-system result";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    gh
    neovim
    btop
    bat
    tree
    nil
    nixd
    nix-output-monitor
    just
  ];

  security.polkit.enable = true;

  # Jupyter-like programs need stdc++ at runtime; nix-ld provides it to
  # foreign dynamically-linked binaries without polluting LD_LIBRARY_PATH globally.
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];
}
