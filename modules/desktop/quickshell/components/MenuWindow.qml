import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
  id: menu

  default property alias menuContent: surface.data
  property alias menuHeight: surface.height
  property alias menuWidth: surface.width
  property string namespace: ""

  signal keyPressed(var event)

  function focusMenu() {
    menuFocus.forceActiveFocus();
  }

  visible: false
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: namespace
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  data: FocusScope {
    id: menuFocus
    anchors.fill: parent
    Keys.onPressed: event => menu.keyPressed(event)

    Surface {
      id: surface
      anchors.bottom: parent.bottom
      anchors.bottomMargin: T.spaceL + T.spaceM
      anchors.horizontalCenter: parent.horizontalCenter
      width: 480
    }
  }
}
