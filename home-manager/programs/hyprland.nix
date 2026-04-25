{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "AQ_DRM_DEVICES,/dev/dri/card2:/dev/dri/card1"
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
      };

      decoration = {
        rounding = 10;
        blur.enabled = false;
      };

      input = {
        natural_scroll = true;
        scroll_factor = 0.8;
        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.8;
        };
      };

      exec-once = [
        "ags run --gtk4"
        "kime"
      ];

      layerrule = [
        "blur, launcher"
        "ignorealpha 0.3, launcher"
      ];

      bind = [
        "SUPER, T, exec, alacritty"
        "SUPER, Q, killactive"

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
      ];
    };
  };
}
