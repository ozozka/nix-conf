import Quickshell
import Quickshell.Wayland
import QtQuick
import "../components" as CM
import "../services" as SV
import ".."

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      property bool showingDate: false

      WlrLayershell.namespace: "quickshell-bar"

      color: T.colO

      implicitHeight: T.spaceL
      anchors {
        bottom: true
        left: true
        right: true
      }

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: T.spaceL

        CM.Workspaces {}
        CM.Submap {}
      }

      Text {
        anchors.centerIn: parent
        text: bar.showingDate ? SV.Clock.date : SV.Clock.time
        color: T.colF
        font.family: "monospace"
        font.pointSize: T.fontSizeB

        TapHandler {
          onTapped: bar.showingDate = !bar.showingDate
        }
      }

      Row {
        anchors.right: parent.right
        anchors.rightMargin: T.spaceL
        anchors.verticalCenter: parent.verticalCenter
        spacing: T.spaceL

        CM.Network {}
        CM.Temperature {}
        CM.Processes {}
        CM.Cpu {}
        CM.Memory {}
        CM.Battery {}
      }
    }
  }
}
