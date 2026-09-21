import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

Repeater {
  id: workspaceLayout
  model: 6

  Text {
    property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

    text: "🞄"

    color: isActive ? T.colF : (ws ? T.colP : T.colM)
    font {
      family: T.fontMono
      pointSize: T.fontSizeB
      bold: true
    }
  }
}
