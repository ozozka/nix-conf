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

      implicitHeight: T.dimM
      anchors {
        bottom: true
        left: true
        right: true
      }

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: T.dimS

        CM.Workspaces {}
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: bar.showingDate ? SV.Clock.date : SV.Clock.time
          color: T.colF
          font.family: "monospace"
          font.pointSize: T.fontSizeM

          TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: (eventPoint, button) => {
              if (button === Qt.LeftButton)
                Quickshell.execDetached(["qs", "ipc", "call", "menu", "toggle"]);
              else if (button === Qt.RightButton)
                bar.showingDate = !bar.showingDate;
            }
          }
        }
        CM.Submap {}
      }

      Row {
        anchors.right: parent.right
        anchors.rightMargin: T.dimS
        anchors.verticalCenter: parent.verticalCenter
        spacing: T.dimS

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
