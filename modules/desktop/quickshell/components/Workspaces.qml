import QtQuick
import Quickshell.Hyprland
import ".."

Row {
  spacing: 0

  Repeater {
    model: 6

    Rectangle {
      id: workspace
      required property int index
      readonly property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
      readonly property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
      readonly property bool occupied: (ws?.toplevels.values.length ?? 0) > 0
      width: glyph.implicitWidth
      height: T.dimM
      color: workspace.isActive ? T.colB : T.colO

      Text {
        id: glyph
        anchors.centerIn: parent
        text: " 🞄 "
        color: workspace.occupied ? T.colF : T.colM
        font {
          family: "monospace"
          pointSize: T.fontSizeM
          bold: true
        }
      }
    }
  }
}
