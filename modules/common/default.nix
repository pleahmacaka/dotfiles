{ pkgs, ... }:

{
  imports = [
    ./nix-base.nix
    ./development.nix
    ./users.nix
  ];

  # Desktop-only caches, appended to the base substituters in nix-base.nix.
  nix.settings = {
    eval-cache = true;

    substituters = [
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];

    builders-use-substitutes = true;
    keep-outputs = true;
    keep-derivations = true;

    max-jobs = "auto";
    cores = 0;

    http-connections = 50;
    max-substitution-jobs = 32;
    download-buffer-size = 268435456;
    connect-timeout = 5;
  };

  nixpkgs.overlays = [
    (self: super: {
      btop = super.btop.override { cudaSupport = true; };
      kime = super.kime.overrideAttrs (old: rec {
        version = "develop-0e846e1";
        src = super.fetchFromGitHub {
          owner = "Riey";
          repo = "kime";
          rev = "0e846e1ed5f31f5d53e99f7a6a84d0391c9870f2";
          hash = "sha256-YkPW0nNa7EkzYHVdVFE7ut0NhVgGeW/E+n7uggYIIEs=";
        };
        cargoDeps = super.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "kime-${version}-vendor";
          hash = "sha256-ZgWHzXixTZWg7+2nXbw2NjeWD/cskGoZ/VSrM7vCwFs=";
        };
        doInstallCheck = false;
      });
    })
  ];

  programs.nix-ld.enable = true;
  programs.neovim = {
    enable = true;
    configure.customRC = ''
      augroup TransparentBg
        autocmd!
        autocmd ColorScheme * highlight Normal       guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight NormalNC     guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight NonText      guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight EndOfBuffer  guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight SignColumn   guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight LineNr       guibg=NONE ctermbg=NONE
        autocmd ColorScheme * highlight VertSplit    guibg=NONE ctermbg=NONE
      augroup END

      highlight Normal      guibg=NONE ctermbg=NONE
      highlight NormalNC    guibg=NONE ctermbg=NONE
      highlight NonText     guibg=NONE ctermbg=NONE
      highlight EndOfBuffer guibg=NONE ctermbg=NONE
      highlight SignColumn  guibg=NONE ctermbg=NONE
      highlight LineNr      guibg=NONE ctermbg=NONE
      highlight VertSplit   guibg=NONE ctermbg=NONE
    '';
  };
  programs.command-not-found.enable = false;
  programs.nix-index.enable = false;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

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
    vlc
    wget
    zip
    unzip
  ];

  security.polkit.enable = true;

  # Jupyter-like programs need stdc++ at runtime; nix-ld provides it to
  # foreign dynamically-linked binaries without polluting LD_LIBRARY_PATH globally.
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc.lib ];
}
