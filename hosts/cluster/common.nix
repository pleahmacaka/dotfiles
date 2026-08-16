{ pkgs, ... }:

let
  operatorKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzV65BUPEPNJqW5FvcxOiYu8zN4TDC6fKzGtQFCJEfk pleahmacaka@nixos-laptop";
in
{
  imports = [
    ../../modules/common/nix-base.nix
    ../../modules/common/users.nix
    ./incus-ct-only.nix
  ];

  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  nixpkgs.flake.setFlakeRegistry = false;
  nixpkgs.flake.setNixPath = false;

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

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [ neovim ];

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  services.tailscale.enable = true;

  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    preseed = null;
  };

  users.users.pleahmacaka.extraGroups = [
    "wheel"
    "incus-admin"
    "i2c"
  ];
  users.users.pleahmacaka.openssh.authorizedKeys.keys = [ operatorKey ];
  users.users.root.openssh.authorizedKeys.keys = [ operatorKey ];

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
