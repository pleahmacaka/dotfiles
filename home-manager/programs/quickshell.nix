{ pkgs, ... }:

let
  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton
    import Quickshell
    import QtQuick

    Singleton {
      readonly property color accent: "#a78bfa"
      readonly property color fg: "#ffffff"
      readonly property color glassBg: Qt.rgba(30/255, 30/255, 40/255, 0.55)
      readonly property color glassBorder: Qt.rgba(1, 1, 1, 0.14)
      readonly property color overlay1: Qt.rgba(1, 1, 1, 0.08)
      readonly property color overlay2: Qt.rgba(1, 1, 1, 0.12)
      readonly property color dotColor: Qt.rgba(1, 1, 1, 0.3)
      readonly property color dotHover: Qt.rgba(1, 1, 1, 0.55)
      readonly property color placeholder: Qt.rgba(1, 1, 1, 0.5)
    }
  '';

  # QML singleton resolution needs Theme.qml in the same dir as its siblings.
  qsSrc = pkgs.runCommandLocal "hm_quickshell" { } ''
    cp -r ${./quickshell} $out
    chmod -R u+w $out
    cp ${themeQml} $out/Theme.qml
  '';
in
{
  home.packages = [
    pkgs.quickshell
    pkgs.qt6.qtdeclarative # qmlls, for Zed's QML LSP
  ];

  # graphical-session.target guarantees WAYLAND_DISPLAY; exec-once raced it.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell (bar, launcher, clipboard)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      # adwaita-qt sets no icon-theme name, so QIcon falls back to hicolor.
      Environment = [
        "QS_REV=${qsSrc}"
        "QT_QPA_PLATFORMTHEME=gtk3"
      ];
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "on-failure";
      # Launcher-spawned apps share this cgroup; a control-group kill takes them too.
      KillMode = "process";
    };
  };

  home.file.".config/quickshell" = {
    source = qsSrc;
    recursive = true;
  };
}
