{ pkgs, ... }:

{
  imports = [
    # ./cuda.nix
    ./development.nix
    ./users.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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

    trusted-users = [
      "root"
      "@wheel"
    ];

    flake-registry = "";
    warn-dirty = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
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
  programs.command-not-found.enable = false;
  programs.nix-index.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      diff-sys = "nvd diff /run/current-system result";
    };
  };

  documentation.nixos.enable = false;

  services.fstrim.enable = true;
  services.dbus.implementation = "broker";
  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
    "kernel.nmi_watchdog" = 0;
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      DNSOverTLS = "true";
      FallbackDNS = [
        "1.1.1.1#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
      ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
    axel
    somo
  ];

  security.polkit.enable = true;

  # Jupyter-like programs need stdc++ at runtime; nix-ld provides it to
  # foreign dynamically-linked binaries without polluting LD_LIBRARY_PATH globally.
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];
}
