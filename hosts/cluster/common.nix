{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/common/users.nix
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    flake-registry = "";
    warn-dirty = false;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Seoul";

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.earlyoom.enable = true;
  services.fstrim.enable = true;
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

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

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    btop
    bat
    tree
    just
    fastfetch
    wget
  ];

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    preseed = null;
  };

  users.users.pleahmacaka.extraGroups = [ "wheel" "incus-admin" ];

  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "incusbr0" ];
    interfaces.tailscale0.allowedTCPPorts = [
      22
      8443
    ];
    interfaces.tailscale0.allowedUDPPorts = [
      8472
    ];
  };

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };
}
