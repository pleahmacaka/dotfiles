{ pkgs, ... }:

{
  imports = [
    # ./cuda.nix
    ./development.nix
    ./users.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "lazy-trees" "parallel-eval" ];
    eval-cache = true;

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];

    builders-use-substitutes = true;
    keep-outputs = true;
    keep-derivations = true;

    auto-optimise-store = true;

    max-jobs = "auto";
    cores = 0;

    http-connections = 50;
    max-substitution-jobs = 32;
    download-buffer-size = 268435456;
    connect-timeout = 5;

    trusted-users = [ "root" "@wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      btop = super.btop.override { cudaSupport = true; };
    })
  ];

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
    fastfetch
  ];

  security.polkit.enable = true;

  # Jupyter-like programs need stdc++ at runtime; nix-ld provides it to
  # foreign dynamically-linked binaries without polluting LD_LIBRARY_PATH globally.
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];
}
