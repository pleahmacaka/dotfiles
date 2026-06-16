{ config, pkgs, osConfig, ... }:

let
  isDark = osConfig.networking.hostName == "nixos-desktop";
  gtkTheme = if isDark then "Adwaita-dark" else "Adwaita";
  qtStyle = if isDark then "adwaita-dark" else "adwaita";
  colorScheme = if isDark then "prefer-dark" else "prefer-light";
in
{
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = gtkTheme;
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk4.theme = config.gtk.theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = qtStyle;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = colorScheme;
      gtk-theme = gtkTheme;
    };
  };
}
