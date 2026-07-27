{ pkgs, ... }:

{
  imports = [
    ../../modules/common/nix-base.nix
    ../../modules/common/users.nix
  ];

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

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [ neovim ];

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

  users.users.pleahmacaka.extraGroups = [
    "wheel"
    "incus-admin"
  ];

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
