import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
  id: widget
  color: T.colO
  required property var menuWindow
  property var anchorItem: null
  property string title: ""
  property Component content: null
  readonly property real inset: T.spaceM
  readonly property real anchorY: anchorItem ? anchorItem.mapToItem(parent, 0, 0).y : menuWindow.menuY

  width: Math.min(380, menuWindow.width - inset * 2)
  height: Math.min(body.implicitHeight + inset * 2, menuWindow.height - T.spaceL - inset * 2)
  x: {
    const beside = menuWindow.menuX + menuWindow.menuWidth + T.spaceS;
    return beside + width + inset <= menuWindow.width ? beside : Math.max(inset, menuWindow.width - width - inset);
  }
  y: Math.max(inset, Math.min(anchorY, menuWindow.height - T.spaceL - inset - height))

  // Consume blank-area clicks, but leave child controls interactive.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
  }

  Flickable {
    anchors {
      fill: parent
      margins: widget.inset
    }
    contentHeight: body.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ColumnLayout {
      id: body
      width: parent.width
      spacing: T.spaceM
      Text {
        Layout.fillWidth: true
        text: widget.title
        color: T.colF
        font.family: T.fontSans
        font.pointSize: T.fontSizeB
        font.bold: true
      }
      Loader {
        Layout.fillWidth: true
        sourceComponent: widget.visible ? widget.content : null
      }
    }
  }
}
