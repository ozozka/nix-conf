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
  property bool alignLeft: false
  property alias widgetContent: widgets.data
  readonly property real menuX: surface.x
  readonly property real menuY: surface.y

  signal keyPressed(var event)
  signal dismissRequested

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

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
      onClicked: menu.dismissRequested()
    }

    Surface {
      id: surface
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
      }
      anchors.bottom: parent.bottom
      anchors.bottomMargin: T.spaceL + T.spaceM
      anchors.left: menu.alignLeft ? parent.left : undefined
      anchors.leftMargin: T.spaceM
      anchors.horizontalCenter: menu.alignLeft ? undefined : parent.horizontalCenter
      width: 480
    }

    Item {
      id: widgets
      anchors.fill: parent
    }
  }
}
