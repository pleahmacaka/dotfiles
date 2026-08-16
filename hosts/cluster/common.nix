{ pkgs, ... }:

let
  operatorKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzV65BUPEPNJqW5FvcxOiYu8zN4TDC6fKzGtQFCJEfk pleahmacaka@nixos-laptop";
  recoveryKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllJnamepHVRtHvhIKLtcxbPscfdjBY9IWFLHtOUWif pleahmacaka@rpi5-02";
  adminKeys = [
    operatorKey
    recoveryKey
  ];
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
    ui.enable = true;
  };

  users.users.pleahmacaka.extraGroups = [
    "wheel"
    "incus-admin"
    "i2c"
  ];
  users.users.pleahmacaka.openssh.authorizedKeys.keys = adminKeys;
  users.users.root.openssh.authorizedKeys.keys = adminKeys;

  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "incusbr0" ];
    allowedTCPPorts = [ 22 ];
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
