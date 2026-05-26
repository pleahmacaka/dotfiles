{ config, pkgs, ... }:

{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.timeout = 1;

  boot.initrd.systemd.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
  };

  fileSystems."/".options = [ "noatime" ];

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;
  services.fwupd.enable = true;
  services.earlyoom.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
  };

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  services.xserver.xkb = {
    layout = "us";
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v12n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "hyprland";
  };

  environment.systemPackages = with pkgs; [
    waybar
    (brave.override { commandLineArgs = "--password-store=gnome-libsecret --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --disable-features=WaylandColorManagementV1"; })
    zed-editor
    tailscale
    claude-code
    vesktop
    wl-clipboard
    cliphist
    hyprshot
    brightnessctl
    obs-studio
    rustdesk-flutter
    python313Packages.huggingface-hub
    usbutils
    unzip
    wget
  ];

  i18n.inputMethod = {
    enable = true;
    type = "kime";
    kime = {
      daemonModules = [ "Wayland" "Indicator" ];
      iconColor = "White";
      extraConfig = ''
        engine:
          hangul:
            layout: dubeolsik
          global_hotkeys:
            AltR:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
            Hangul:
              behavior: !Toggle
              - Hangul
              - Latin
              result: Consume
      '';
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      pretendard
      nanum
      d2coding
      terminus_font
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK KR" "Noto Serif" ];
        sansSerif = [ "Pretendard" "Noto Sans CJK KR" "Noto Sans" ];
        monospace = [ "D2Coding" "Noto Sans Mono CJK KR" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.zsh.enable = true;

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.upower.enable = true;

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  services.asusd.enable = true;
  services.supergfxd.enable = true;

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedTCPPorts = [ 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];

  users.users.pleahmacaka.extraGroups = [
    "video"
    "audio"
    "dialout"
  ];

  system.stateVersion = "26.04";
}
