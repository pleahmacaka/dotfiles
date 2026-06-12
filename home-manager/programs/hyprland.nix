{ osConfig, ... }:

let
  hostName = osConfig.networking.hostName;
  isOfficeDesktop = hostName == "nixos-office-desktop";
  isDark = hostName == "nixos-desktop";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "LIBVA_DRIVER_NAME,radeonsi"
        "__GLX_VENDOR_LIBRARY_NAME,mesa"
        "GTK_IM_MODULE,kime"
        "QT_IM_MODULE,kime"
        "XMODIFIERS,@im=kime"
      ];

      monitor =
        if isOfficeDesktop then
          [
            "HDMI-A-1,2560x1440@144,0x0,1"
            "DP-1,2560x1440@144,-2560x0,1"
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
        repeat_delay = 150;
        repeat_rate = 50;
        kb_options = "korean:ralt:hangul,korean:rctrl_hanja";
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.3;
          disable_while_typing = false;
        };
      };

      exec-once = [
        "ags run --gtk4"
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

        "float, title:^(Open File)(.*)$"
        "float, title:^(Save File)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Open)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose Files)(.*)$"
        "float, title:^(File Upload)(.*)$"
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

        "center, title:^(Open File)(.*)$"
        "center, title:^(Save File)(.*)$"
        "center, title:^(Save As)(.*)$"
        "center, title:^(Open)(.*)$"
        "center, title:^(Select a File)(.*)$"
        "center, title:^(Choose Files)(.*)$"
        "center, title:^(File Upload)(.*)$"
        "center, class:^(xdg-desktop-portal-gtk)$"
      ];

      bind = [
        "SUPER, T, exec, ghostty"
        "SUPER, E, exec, nautilus"
        "SUPER, Q, killactive"

        "SUPER SHIFT, S, exec, hyprshot -m region --freeze --clipboard-only --silent"
        "SUPER, V, exec, ags request clipboard-toggle"

        "SUPER, P, togglefloating,"

        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"

        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"

        "SUPER, left,  movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up,    movefocus, u"
        "SUPER, down,  movefocus, d"
      ];

      bindr = [
        "SUPER, SUPER_L, exec, ags request toggle"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
        "SUPER CTRL, mouse:272, resizewindow"
      ];
    };
  };
}
