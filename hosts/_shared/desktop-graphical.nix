{ pkgs, isLaptop, inputs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  termius =
    if isLaptop then
      pkgs.symlinkJoin {
        name = "termius-scaled";
        paths = [ pkgs.termius ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/termius-app \
            --add-flags "--force-device-scale-factor=1.25"
        '';
      }
    else
      pkgs.termius;
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
    "pnpm-10.29.2"
  ];

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

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;

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
    config.common = {
      default = "hyprland";
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };

  environment.systemPackages = with pkgs; [
    waybar
    (brave.override {
      commandLineArgs = "--password-store=gnome-libsecret --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --disable-features=WaylandColorManagementV1 --enable-wayland-ime";
    })
    zed-editor
    llmAgents.claude-code # numtide/llm-agents.nix, replaces nixpkgs claude-code
    llmAgents.reasonix
    opencode
    vesktop
    termius
    wl-clipboard
    cliphist
    obs-studio
    python313Packages.huggingface-hub
    usbutils
    rustdesk-flutter
    bitwarden-desktop
    nautilus
    obsidian
    libreoffice-fresh
    cifs-utils
    agenix
    gnome-boxes
    virtio-win
    phodav
  ];

  environment.shellAliases.zed = "SHELL=$(getent passwd $USER | cut -d: -f7) zeditor";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

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
            layout_addons:
              all: []
              dubeolsik:
                - TreatJongseongAsChoseong
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

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
  };
  hardware.printers = {
    ensureDefaultPrinter = "Canon_C3530";
    ensurePrinters = [
      {
        name = "Canon_C3530";
        location = "Office";
        deviceUri = "socket://192.168.0.100:9100";
        model = "CNRCUPSIR3530ZK.ppd";
      }
    ];
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.samba-wsdd.enable = true;

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
    "libvirtd"
    "kvm"
  ];

  system.stateVersion = "26.04";
}
