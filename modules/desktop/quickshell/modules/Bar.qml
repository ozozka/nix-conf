import Quickshell
import Quickshell.Wayland
import QtQuick
import "../components" as CM
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

      color: T.colB
      BackgroundEffect.blurRegion: Region {
        item: bar.contentItem
      }

      implicitHeight: T.spaceL
      anchors {
        bottom: true
        left: true
        right: true
      }

      Row {
        anchors.left: parent.left
        anchors.leftMargin: T.spaceL
        anchors.verticalCenter: parent.verticalCenter
        spacing: T.spaceL

        CM.Workspaces {}
        CM.Language {}
        CM.Audio {}
        CM.Submap {}
      }

      Item {
        anchors.centerIn: parent
        width: bar.showingDate ? date.implicitWidth : time.implicitWidth
        height: bar.showingDate ? date.implicitHeight : time.implicitHeight

        CM.Time {
          id: time
          anchors.centerIn: parent
          visible: !bar.showingDate
        }

        CM.Date {
          id: date
          anchors.centerIn: parent
          visible: bar.showingDate
        }

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
        CM.Cpu {}
        CM.Memory {}
        CM.Battery {}
      }
    }
  }
}
