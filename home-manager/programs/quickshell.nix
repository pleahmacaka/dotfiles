{ pkgs, osConfig, ... }:

let
  # Match theme.nix: only nixos-desktop is dark, everything else is light.
  isDark = osConfig.networking.hostName == "nixos-desktop";

  # isDark is now runtime: read the same dconf key the dark/light shell aliases
  # write, and watch it so toggling reaches the bar without a rebuild. The
  # hostname value is only the boot default until dconf is read.
  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton
    import Quickshell
    import Quickshell.Io
    import QtQuick

    Singleton {
      id: root
      property bool isDark: ${if isDark then "true" else "false"}

      readonly property color accent: "#a78bfa"
      readonly property color fg: isDark ? "#ffffff" : "#1e1e2e"
      readonly property color glassBg: isDark ? Qt.rgba(30/255, 30/255, 40/255, 0.55) : Qt.rgba(245/255, 245/255, 248/255, 0.7)
      readonly property color glassBorder: isDark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)
      readonly property color overlay1: isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)
      readonly property color overlay2: isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10)
      readonly property color dotColor: isDark ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(0, 0, 0, 0.3)
      readonly property color dotHover: isDark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.55)
      readonly property color placeholder: isDark ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.45)

      function apply(line) {
        if (line.indexOf("prefer-dark") !== -1) root.isDark = true;
        else if (line.indexOf("prefer-light") !== -1) root.isDark = false;
      }

      // Initial value (empty if dconf unset -> keep hostname default).
      Process {
        running: true
        command: ["${pkgs.dconf}/bin/dconf", "read", "/org/gnome/desktop/interface/color-scheme"]
        stdout: StdioCollector { onStreamFinished: root.apply(this.text) }
      }
      // Live toggle: dconf watch prints the new value on every write.
      Process {
        running: true
        command: ["${pkgs.dconf}/bin/dconf", "watch", "/org/gnome/desktop/interface/color-scheme"]
        stdout: SplitParser { onRead: line => root.apply(line) }
      }
    }
  '';

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
