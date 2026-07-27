{
  osConfig,
  pkgs,
  isDark,
  isLaptop,
  isOfficeDesktop,
  ...
}:

let
  # Titles GTK/portal file pickers use; matched to float and center them.
  fileDialogTitles = [
    "Open File"
    "Save File"
    "Save As"
    "Open"
    "Select a File"
    "Choose Files"
    "File Upload"
  ];
  workspaceIds = [
    1
    2
    3
    4
    5
  ];
  wallpaper = if isDark then ../wallpapers/nix-dark.png else ../wallpapers/nix-bright.png;
  isNvidia = builtins.elem "nvidia" (osConfig.services.xserver.videoDrivers or [ ]);

  hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
in
{
  home.packages = [
    pkgs.swaybg
    pkgs.hyprshot
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      xwayland.force_zero_scaling = isLaptop;

      env = [
        "LIBVA_DRIVER_NAME,radeonsi"
        "__GLX_VENDOR_LIBRARY_NAME,mesa"
        "GTK_IM_MODULE,kime"
        "QT_IM_MODULE,kime"
        "XMODIFIERS,@im=kime"
        "XCURSOR_THEME,Adwaita"
        "XCURSOR_SIZE,24"
      ];

      monitor =
        if isOfficeDesktop then
          [
            "HDMI-A-1,2560x1440@144,0x0,1"
            "DP-1,2560x1440@144,-2560x0,1"
          ]
        else if isLaptop then
          [
            "eDP-2,preferred,auto,1.25"
            ",preferred,auto,auto"
          ]
        else
          [ ",preferred,auto,auto" ];

      workspace =
        if isOfficeDesktop then
          [
            "1, monitor:HDMI-A-1, default:true, persistent:true"
            "2, monitor:HDMI-A-1, persistent:true"
            "3, monitor:HDMI-A-1, persistent:true"
            "4, monitor:HDMI-A-1, persistent:true"
            "5, monitor:HDMI-A-1, persistent:true"
            "10, monitor:DP-1, default:true, persistent:true"
          ]
        else
          [ ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(b8a6f5cc) rgba(8b6fd9cc) 45deg";
        "col.inactive_border" = "rgba(1e1e2888)";
      };

      decoration = {
        rounding = 10;
        blur.enabled = true;
        shadow.enabled = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = if isDark then "0x000000" else "0xece8f3";
      };

      cursor = {
        no_hardware_cursors = isNvidia;
      };

      animations = {
        enabled = true;
        animation = [
          "border, 1, 1.2, default"
          "borderangle, 1, 1.2, default"
          "workspaces, 1, 4, default, slidevert"
          "specialWorkspace, 1, 4, default, slidevert"
        ];
      };

      input = {
        sensitivity = -0.17;
        natural_scroll = false;
        repeat_delay = 250;
        repeat_rate = 40;
        kb_options = "korean:ralt:hangul,korean:rctrl_hanja";
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.3;
          disable_while_typing = false;
        };
      };

      exec-once = [
        "swaybg -m fill -i ${wallpaper}"
        "kime"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      layerrule = [
        "match:namespace ^(launcher)$, blur 1, ignore_alpha 0.3"
        "match:namespace ^(notifications)$, blur 1, ignore_alpha 0.4"
      ];

      "windowrule[]" = [
        "float, class:^(scrcpy)$"
        "size 432 936, class:^(scrcpy)$"
        "center, class:^(scrcpy)$"
        "pin, class:^(scrcpy)$"
      ]
      ++ map (t: "float, title:^(${t})(.*)$") fileDialogTitles
      ++ [
        "float, title:^(Library)(.*)$"
        "float, class:^(xdg-desktop-portal-gtk)$"
        "float, class:^(xdg-desktop-portal-hyprland)$"
        "float, class:^(org.freedesktop.impl.portal.desktop.gtk)$"
        "float, class:^(org.gnome.FileRoller)$"
        "float, class:^(file-roller)$"
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(blueman-manager)$"
        "float, title:^(Picture-in-Picture)$"
        "float, title:^(.*)(Bitwarden)(.*)$"
      ]
      ++ map (t: "center, title:^(${t})(.*)$") fileDialogTitles
      ++ [
        "center, class:^(xdg-desktop-portal-gtk)$"
        "opacity 0.95 0.92, class:^(brave-browser)$"
      ];

      bind = [
        "SUPER, T, exec, alacritty"
        "SUPER, E, exec, nautilus"
        "SUPER, Q, killactive"

        "SUPER SHIFT, S, exec, ${hyprshot} -m region --clipboard-only --freeze"
        "SUPER SHIFT, W, exec, ${hyprshot} -m window --clipboard-only --freeze"
        "SUPER, V, exec, qs ipc call shell toggleClipboard"

        "SUPER, P, togglefloating,"
      ]
      ++ map (n: "SUPER, ${toString n}, workspace, ${toString n}") workspaceIds
      ++ map (n: "SUPER SHIFT, ${toString n}, movetoworkspace, ${toString n}") workspaceIds
      ++ [
        "SUPER, left,  movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up,    movefocus, u"
        "SUPER, down,  movefocus, d"
      ];

      bindr = [
        "SUPER, SUPER_L, exec, qs ipc call shell toggleLauncher"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
        "SUPER CTRL, mouse:272, resizewindow"
      ];
    };
  };
}
