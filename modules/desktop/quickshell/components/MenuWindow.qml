import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
  id: menu

  default property alias menuContent: surface.data
  property alias menuHeight: surface.height
  property alias menuWidth: surface.width
  property alias widgetContent: widgets.data
  readonly property real menuX: surface.x
  readonly property real menuY: surface.y

  signal keyPressed(var event)
  signal dismissRequested

  visible: false
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "quickshell-menu"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  data: FocusScope {
    anchors.fill: parent
    Keys.onPressed: event => menu.keyPressed(event)

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onClicked: menu.dismissRequested()
    }

    Rectangle {
      id: surface
      color: T.colO
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
      }
      anchors.bottom: parent.bottom
      anchors.bottomMargin: T.spaceL + T.spaceM
      anchors.left: parent.left
      anchors.leftMargin: T.spaceM
      width: 480
    }

    Item {
      id: widgets
      anchors.fill: parent
    }
  }
}
