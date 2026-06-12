{ pkgs, ... }:

{
  # bitwarden-desktop currently depends on electron-39, which nixpkgs marks insecure.
  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.initrd.systemd.enable = true;

  fileSystems."/".options = [ "noatime" ];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "50%";
  };

  networking.networkmanager.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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

  services.xserver.xkb.layout = "us";

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
    (brave.override {
      commandLineArgs = "--password-store=gnome-libsecret --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --disable-features=WaylandColorManagementV1 --enable-wayland-ime";
    })
    zed-editor
    tailscale
    claude-code
    vesktop
    wl-clipboard
    cliphist
    hyprshot
    obs-studio
    python313Packages.huggingface-hub
    usbutils
    rustdesk-flutter
    bitwarden-desktop
  ];

  i18n.inputMethod = {
    enable = true;
    type = "kime";
    kime = {
      daemonModules = [
        "Xim"
        "Wayland"
        "Indicator"
      ];
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
        serif = [
          "Noto Serif CJK KR"
          "Noto Serif"
        ];
        sansSerif = [
          "Pretendard"
          "Noto Sans CJK KR"
          "Noto Sans"
        ];
        monospace = [
          "D2Coding"
          "Noto Sans Mono CJK KR"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.zsh.enable = true;

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

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

  users.users.pleahmacaka.extraGroups = [
    "video"
    "audio"
    "dialout"
  ];

  system.stateVersion = "26.04";
}
