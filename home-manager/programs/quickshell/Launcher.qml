import Quickshell
import Quickshell.Wayland
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

  property var results: []

  function rank(app, q) {
    const n = app.name.toLowerCase();
    if (n.startsWith(q)) return 0;
    if (n.includes(q)) return 1;
    return 2;
  }

  function refresh(q) {
    const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);
    if (q === "") {
      results = apps.slice().sort((a, b) => a.name.localeCompare(b.name));
    } else {
      const ql = q.toLowerCase();
      results = apps
        .filter(a => a.name.toLowerCase().includes(ql) || (a.comment || "").toLowerCase().includes(ql))
        .sort((a, b) => rank(a, ql) - rank(b, ql) || a.name.localeCompare(b.name))
        .slice(0, 30);
    }
  }

  function launch(app) {
    if (!app) return;
    hide();
    app.execute();
  }

  onVisibleChanged: {
    if (visible) {
      DesktopEntries.applications; // ensure loaded
      search.text = "";
      refresh("");
      search.forceActiveFocus();
    }
  }

  // click outside closes
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

    MouseArea { anchors.fill: parent } // swallow clicks on the panel

    Column {
      id: content
      anchors.fill: parent
      anchors.margins: 10
      spacing: 4

      // search box
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
          source: Quickshell.iconPath("system-search-symbolic", "edit-find")
        }
        TextInput {
          id: search
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 60
          color: Theme.fg
          font.pixelSize: 16
          clip: true
          onTextChanged: root.refresh(text)
          Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: search.text === ""
            color: Theme.placeholder
            font: search.font
            text: "Search applications..."
          }
          Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Escape) {
              root.hide(); e.accepted = true;
            } else if (e.modifiers & Qt.AltModifier) {
              const n = e.key - Qt.Key_1;
              if (n >= 0 && n <= 8) { root.launch(root.results[n]); e.accepted = true; }
            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
              root.launch(root.results[0]); e.accepted = true;
            }
          }
        }
      }

      // results
      ListView {
        width: parent.width
        height: 520
        clip: true
        model: root.results
        boundsBehavior: Flickable.StopAtBounds
        // Recycle delegates and pre-render a screenful above/below so flicking
        // doesn't rebuild rows + reload icons on every frame.
        reuseItems: true
        cacheBuffer: 1120
        delegate: Rectangle {
          required property var modelData
          required property int index
          width: ListView.view.width
          height: 56
          radius: 10
          color: itemMa.containsMouse ? Theme.overlay1 : "transparent"

          Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12
            Image {
              anchors.verticalCenter: parent.verticalCenter
              width: 36; height: 36
              source: Quickshell.iconPath(modelData.icon, "application-x-executable")
              fillMode: Image.PreserveAspectFit
              // Render at display size (not the provider's default 100px) and
              // off-thread, so scrolling stays smooth.
              sourceSize.width: 36
              sourceSize.height: 36
              asynchronous: true
            }
            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 48 - (index < 9 ? 60 : 0)
              Text {
                width: parent.width
                color: Theme.fg
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
                text: modelData.name
              }
              Text {
                width: parent.width
                visible: !!modelData.comment
                color: Theme.fg
                opacity: 0.5
                font.pixelSize: 11
                elide: Text.ElideRight
                text: modelData.comment || ""
              }
            }
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            visible: index < 9
            color: Theme.fg
            opacity: 0.35
            font.pixelSize: 11
            font.family: "monospace"
            text: "Alt+" + (index + 1)
          }
          MouseArea {
            id: itemMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.launch(modelData)
          }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.results.length === 0 && search.text !== ""
        color: Theme.fg
        opacity: 0.55
        font.pixelSize: 13
        padding: 20
        text: "No results"
      }
    }
  }
}
