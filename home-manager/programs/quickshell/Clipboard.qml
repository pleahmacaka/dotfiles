import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
  id: root
  visible: false

  function toggle() { visible = !visible; }
  function hide() { visible = false; }

  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  WlrLayershell.namespace: "launcher"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  readonly property int maxResults: 8
  property var all: []      // [{id, preview}]
  property var results: []

  function filter(q) {
    if (q === "") {
      results = all.slice(0, maxResults);
    } else {
      const ql = q.toLowerCase();
      results = all.filter(e => e.preview.toLowerCase().includes(ql)).slice(0, maxResults);
    }
  }

  function paste(entry) {
    if (!entry) return;
    hide();
    pasteProc.command = ["sh", "-c", "cliphist decode " + entry.id + " | wl-copy"];
    pasteProc.running = true;
  }

  Process {
    id: listProc
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.all = this.text.split("\n").filter(l => l.length > 0).map(line => {
          const tab = line.indexOf("\t");
          return tab === -1
            ? { id: line, preview: line }
            : { id: line.slice(0, tab), preview: line.slice(tab + 1) };
        });
        root.filter(search.text);
      }
    }
  }

  Process { id: pasteProc }

  onVisibleChanged: {
    if (visible) {
      search.text = "";
      listProc.running = true;
      search.forceActiveFocus();
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.hide()
  }

  Rectangle {
    id: panel
    width: 540
    anchors.centerIn: parent
    height: content.implicitHeight + 20
    color: Theme.glassBg
    radius: 18
    border.color: Theme.glassBorder
    border.width: 1

    MouseArea { anchors.fill: parent }

    Column {
      id: content
      anchors.fill: parent
      anchors.margins: 10
      spacing: 4

      Row {
        width: parent.width
        spacing: 8
        leftPadding: 12
        topPadding: 8
        bottomPadding: 8
        Image {
          anchors.verticalCenter: parent.verticalCenter
          width: 20; height: 20
          opacity: 0.6
          source: Quickshell.iconPath("edit-paste-symbolic", "edit-paste")
        }
        TextInput {
          id: search
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 60
          color: Theme.fg
          font.pixelSize: 16
          clip: true
          onTextChanged: root.filter(text)
          Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: search.text === ""
            color: Theme.placeholder
            font: search.font
            text: "Search clipboard..."
          }
          Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Escape) {
              root.hide(); e.accepted = true;
            } else if (e.modifiers & Qt.AltModifier) {
              const n = e.key - Qt.Key_1;
              if (n >= 0 && n <= 7) { root.paste(root.results[n]); e.accepted = true; }
            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
              root.paste(root.results[0]); e.accepted = true;
            }
          }
        }
      }

      Repeater {
        model: root.results
        delegate: Rectangle {
          required property var modelData
          required property int index
          width: content.width
          height: 56
          radius: 10
          color: rowMa.containsMouse ? Theme.overlay1 : "transparent"
          Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12
            Image {
              anchors.verticalCenter: parent.verticalCenter
              width: 36; height: 36
              opacity: 0.7
              source: Quickshell.iconPath("edit-paste-symbolic", "edit-paste")
              fillMode: Image.PreserveAspectFit
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 48 - 60
              color: Theme.fg
              font.pixelSize: 14
              elide: Text.ElideRight
              text: modelData.preview
            }
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            color: Theme.fg
            opacity: 0.35
            font.pixelSize: 11
            font.family: "monospace"
            text: "Alt+" + (index + 1)
          }
          MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.paste(modelData)
          }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.results.length === 0
        color: Theme.fg
        opacity: 0.55
        font.pixelSize: 13
        padding: 20
        text: search.text === "" ? "Clipboard is empty" : "No results"
      }
    }
  }
}
