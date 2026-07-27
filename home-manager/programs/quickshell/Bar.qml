import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick

PanelWindow {
  id: bar
  required property var modelData
  screen: modelData

  anchors { top: true; bottom: true; left: true }
  implicitWidth: 56
  exclusiveZone: 56
  color: "transparent"
  WlrLayershell.namespace: "bar"

  Rectangle {
    anchors.fill: parent
    color: Theme.glassBg
    topRightRadius: 18
    bottomRightRadius: 18
    border.color: Theme.glassBorder
    border.width: 1

    Column {
      id: workspaces
      anchors.top: parent.top
      anchors.topMargin: 12
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 8

      Repeater {
        model: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id)
        delegate: Rectangle {
          required property var modelData
          readonly property bool active: Hyprland.focusedWorkspace
            && Hyprland.focusedWorkspace.id === modelData.id
          width: 10
          height: active ? 22 : 10
          radius: 5
          color: active ? Theme.accent : (ma.containsMouse ? Theme.dotHover : Theme.dotColor)
          Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
          Behavior on color { ColorAnimation { duration: 200 } }
          MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Hyprland.dispatch("workspace " + modelData.id)
          }
        }
      }
    }

    SystemClock {
      id: clock
      precision: SystemClock.Minutes
    }

    Rectangle {
      id: clockBtn
      anchors.centerIn: parent
      width: clockCol.width + 8
      height: clockCol.height + 8
      radius: 8
      color: clockMa.containsMouse ? Theme.overlay1 : "transparent"

      Column {
        id: clockCol
        anchors.centerIn: parent
        spacing: 0
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          font.pixelSize: 13
          font.weight: Font.DemiBold
          text: (clock.date.getHours() % 12 || 12) + ":" + String(clock.date.getMinutes()).padStart(2, "0")
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          opacity: 0.6
          font.pixelSize: 9
          font.weight: Font.DemiBold
          text: clock.date.getHours() < 12 ? "AM" : "PM"
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          opacity: 0.55
          font.pixelSize: 10
          topPadding: 3
          text: clock.date.toLocaleDateString(Qt.locale("ko_KR"), "ddd ") +
            (clock.date.getMonth() + 1) + "/" + clock.date.getDate()
        }
      }
      MouseArea {
        id: clockMa
        anchors.fill: parent
        hoverEnabled: true
        onClicked: calendar.visible = !calendar.visible
      }
    }

    Column {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6

      Repeater {
        model: SystemTray.items.values
        delegate: Item {
          required property var modelData
          width: 28
          height: 28
          // Unresolvable icons render as a broken texture, so hide them.
          visible: trayImg.status !== Image.Error
          Image {
            id: trayImg
            anchors.centerIn: parent
            width: 16
            height: 16
            source: modelData.icon
            fillMode: Image.PreserveAspectFit
          }
          MouseArea {
            id: trayMa
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (e) => {
              if (e.button === Qt.RightButton || modelData.onlyMenu) {
                if (modelData.hasMenu) menuAnchor.open();
              } else {
                modelData.activate();
              }
            }
          }
          QsMenuAnchor {
            id: menuAnchor
            menu: modelData.menu
            anchor.window: bar
            anchor.rect.x: bar.width
            anchor.rect.y: trayMa.mapToItem(null, 0, 0).y
            anchor.edges: Edges.Right
            anchor.gravity: Edges.Right | Edges.Bottom
          }
        }
      }

      Rectangle {
        width: 28
        height: 28
        radius: 8
        color: notifMa.containsMouse ? Theme.overlay1 : "transparent"
        Text {
          anchors.centerIn: parent
          font.pixelSize: 14
          text: "🔔"
        }
        MouseArea {
          id: notifMa
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            notifPopup.visible = !notifPopup.visible;
            if (notifPopup.visible) notifPopup.refresh();
          }
        }
      }

      Column {
        spacing: 2
        readonly property var bat: UPower.displayDevice
        visible: bat && bat.isLaptopBattery
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          font.pixelSize: 11
          text: parent.bat && parent.bat.state === UPowerDeviceState.Charging ? "⚡" : "🔋"
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          font.pixelSize: 11
          font.weight: Font.Medium
          text: parent.bat ? Math.round(parent.bat.percentage * 100) + "%" : ""
        }
      }
    }
  }

  PopupWindow {
    id: calendar
    visible: false
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: bar.width + 4
    anchor.rect.y: (bar.height - calendar.implicitHeight) / 2
    implicitWidth: 232
    implicitHeight: calBox.implicitHeight

    property date shown: clock.date

    HyprlandFocusGrab {
      windows: [calendar]
      active: calendar.visible
      onCleared: calendar.visible = false
    }

    Rectangle {
      id: calBox
      anchors.fill: parent
      color: Theme.glassBg
      radius: 12
      border.color: Theme.glassBorder
      border.width: 1
      implicitHeight: calCol.implicitHeight + 20

      Column {
        id: calCol
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.fg
          font.pixelSize: 13
          font.weight: Font.DemiBold
          text: calendar.shown.getFullYear() + "." + (calendar.shown.getMonth() + 1)
        }

        Grid {
          anchors.horizontalCenter: parent.horizontalCenter
          columns: 7
          spacing: 2

          Repeater {
            model: ["일", "월", "화", "수", "목", "금", "토"]
            delegate: Text {
              required property var modelData
              width: 28; height: 20
              horizontalAlignment: Text.AlignHCenter
              color: Theme.fg
              opacity: 0.5
              font.pixelSize: 10
              text: modelData
            }
          }

          Repeater {
            model: {
              const y = calendar.shown.getFullYear();
              const m = calendar.shown.getMonth();
              const first = new Date(y, m, 1).getDay();
              const days = new Date(y, m + 1, 0).getDate();
              const cells = [];
              for (let i = 0; i < first; i++) cells.push(0);
              for (let d = 1; d <= days; d++) cells.push(d);
              return cells;
            }
            delegate: Item {
              required property var modelData
              width: 28; height: 24
              readonly property bool today: modelData === clock.date.getDate()
                && calendar.shown.getMonth() === clock.date.getMonth()
              Text {
                anchors.centerIn: parent
                visible: modelData > 0
                color: parent.today ? Theme.accent : Theme.fg
                font.pixelSize: 11
                font.weight: parent.today ? Font.Bold : Font.Normal
                text: modelData > 0 ? modelData : ""
              }
            }
          }
        }
      }
    }
  }

  PopupWindow {
    id: notifPopup
    visible: false
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: bar.width + 4
    anchor.rect.y: bar.height - notifPopup.implicitHeight - 80
    implicitWidth: 300
    implicitHeight: Math.min(notifBox.implicitHeight, 500)

    property var items: []

    HyprlandFocusGrab {
      windows: [notifPopup]
      active: notifPopup.visible
      onCleared: notifPopup.visible = false
    }

    function refresh() {
      histProc.running = true;
    }

    Process {
      id: histProc
      command: ["makoctl", "history"]
      stdout: StdioCollector {
        onStreamFinished: {
          try {
            const parsed = JSON.parse(this.text);
            const raw = (parsed.data && parsed.data[0]) || [];
            notifPopup.items = raw.slice(-20).reverse().map(it => {
              const s = (it.summary && it.summary.data) || "";
              const b = (it.body && it.body.data) || "";
              return b ? s + "\n" + b : s;
            });
          } catch (e) {
            notifPopup.items = [];
          }
        }
      }
    }

    Process { id: dismissProc; command: ["makoctl", "dismiss", "--all"] }

    Rectangle {
      id: notifBox
      anchors.fill: parent
      color: Theme.glassBg
      radius: 12
      border.color: Theme.glassBorder
      border.width: 1
      implicitHeight: notifCol.implicitHeight + 16

      Column {
        id: notifCol
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Text {
          visible: notifPopup.items.length === 0
          color: Theme.fg
          opacity: 0.5
          font.pixelSize: 12
          padding: 12
          text: "기록 없음"
        }

        Repeater {
          model: notifPopup.items
          delegate: Rectangle {
            required property var modelData
            width: notifCol.width
            height: txt.implicitHeight + 16
            radius: 8
            color: Theme.overlay1
            Text {
              id: txt
              anchors.fill: parent
              anchors.margins: 8
              color: Theme.fg
              font.pixelSize: 12
              wrapMode: Text.WordWrap
              text: modelData
            }
          }
        }

        Rectangle {
          width: notifCol.width
          height: 30
          radius: 8
          color: clearMa.containsMouse ? Qt.rgba(0.65, 0.55, 0.98, 0.25) : Qt.rgba(0.65, 0.55, 0.98, 0.15)
          border.color: Qt.rgba(0.65, 0.55, 0.98, 0.3)
          border.width: 1
          Text {
            anchors.centerIn: parent
            color: Theme.fg
            font.pixelSize: 11
            text: "모두 닫기"
          }
          MouseArea {
            id: clearMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { dismissProc.running = true; notifPopup.refresh(); }
          }
        }
      }
    }
  }
}
