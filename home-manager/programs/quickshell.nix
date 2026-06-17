{ pkgs, osConfig, ... }:

let
  # Match theme.nix: only nixos-desktop is dark, everything else is light.
  isDark = osConfig.networking.hostName == "nixos-desktop";

  themeQml = pkgs.writeText "Theme.qml" (''
    pragma Singleton
    import Quickshell
    import QtQuick

    Singleton {
      readonly property color accent: "#a78bfa"
  '' + (
    if isDark then ''
      readonly property color fg: "#ffffff"
      readonly property color glassBg: Qt.rgba(30/255, 30/255, 40/255, 0.55)
      readonly property color glassBorder: Qt.rgba(1, 1, 1, 0.14)
      readonly property color overlay1: Qt.rgba(1, 1, 1, 0.08)
      readonly property color overlay2: Qt.rgba(1, 1, 1, 0.12)
      readonly property color dotColor: Qt.rgba(1, 1, 1, 0.3)
      readonly property color dotHover: Qt.rgba(1, 1, 1, 0.55)
      readonly property color placeholder: Qt.rgba(1, 1, 1, 0.5)
    }
    '' else ''
      readonly property color fg: "#1e1e2e"
      readonly property color glassBg: Qt.rgba(245/255, 245/255, 248/255, 0.7)
      readonly property color glassBorder: Qt.rgba(0, 0, 0, 0.12)
      readonly property color overlay1: Qt.rgba(0, 0, 0, 0.06)
      readonly property color overlay2: Qt.rgba(0, 0, 0, 0.10)
      readonly property color dotColor: Qt.rgba(0, 0, 0, 0.3)
      readonly property color dotHover: Qt.rgba(0, 0, 0, 0.55)
      readonly property color placeholder: Qt.rgba(0, 0, 0, 0.45)
    }
    ''
  ));

  # Bundle the QML sources with the generated Theme.qml in one store dir so
  # singleton/sibling component resolution sees them all together.
  qsSrc = pkgs.runCommandLocal "hm_quickshell" { } ''
    cp -r ${./quickshell} $out
    chmod -R u+w $out
    cp ${themeQml} $out/Theme.qml
  '';
in
{
  home.packages = [ pkgs.quickshell ];

  # Same rationale as the old ags service: bind to graphical-session.target so
  # WAYLAND_DISPLAY is imported before start (exec-once raced that on boot).
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell (bar, launcher, clipboard)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      # adwaita-qt (the global qt.platformTheme) never sets Qt's icon-theme
      # name, so QIcon falls back to hicolor and most tray/symbolic icons fail.
      # gtk3 reads the configured GTK Adwaita icon theme. Pure-QML, so this
      # doesn't change app styling — it only fixes icon resolution.
      Environment = [
        "QS_REV=${qsSrc}"
        "QT_QPA_PLATFORMTHEME=gtk3"
      ];
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "on-failure";
      # Launcher-spawned apps (brave/vesktop) inherit this unit's cgroup, so the
      # default control-group kill takes them down on `reload`/switch restarts.
      # KillMode=process signals only qs; the launched apps survive (reparented).
      KillMode = "process";
    };
  };

  home.file.".config/quickshell" = {
    source = qsSrc;
    recursive = true;
  };
}
