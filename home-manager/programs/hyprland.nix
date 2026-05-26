{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "AQ_DRM_DEVICES,/dev/dri/card2"
        "LIBVA_DRIVER_NAME,radeonsi"
        "__GLX_VENDOR_LIBRARY_NAME,mesa"
        "WLR_NO_HARDWARE_CURSORS,1"
        "NVD_BACKEND,direct"
      ];

      monitor = [
        ",preferred,auto,1"
      ];

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
        background_color = "0x000000";
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

      bind = [
        "SUPER, T, exec, ghostty"
        "SUPER, Q, killactive"

        "SUPER SHIFT, S, exec, hyprshot -m region --freeze --clipboard-only --silent"
        "SUPER, V, exec, ags request clipboard-toggle"

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
