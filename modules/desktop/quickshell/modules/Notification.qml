import QtQuick
import Quickshell
import Quickshell.Wayland
import "../components" as CM
import "../services" as SV
import ".."

Scope {
  required property var focusedScreen

  Connections {
    target: SV.NotificationStore
    function onPromoted() {
      if (focusedScreen)
        popupWindow.screen = focusedScreen;
      Qt.callLater(() => stack.contentY = 0);
    }
  }

  ScriptModel {
    id: popupModel
    values: SV.NotificationStore.states
  }

  PanelWindow {
    id: popupWindow
    visible: popupModel.values.length > 0
    color: "transparent"
    implicitWidth: Math.min(444, (screen?.width ?? 1920) - T.spaceM * 2)
    implicitHeight: Math.min(popupColumn.implicitHeight, (screen?.height ?? 1080) - T.spaceL - T.spaceM * 2)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors {
      bottom: true
      right: true
    }
    margins {
      bottom: T.spaceL + T.spaceM
      right: T.spaceM
    }

    Flickable {
      id: stack
      anchors.fill: parent
      contentHeight: popupColumn.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Column {
        id: popupColumn
        width: stack.width
        spacing: T.spaceS
        Repeater {
          model: popupModel
          CM.NotificationCard {
            required property var modelData
            width: popupColumn.width
            notificationState: modelData
          }
        }
      }
    }
  }
}
