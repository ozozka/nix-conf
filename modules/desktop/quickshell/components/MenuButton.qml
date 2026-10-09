import QtQuick
import QtQuick.Controls
import ".."

Button {
  id: button
  property bool selected: false
  property string symbol: ""
  property string symbolFamily: T.fontMono
  property string valueText: ""
  property bool muted: false
  implicitHeight: T.spaceL + T.spaceS
  implicitWidth: contentItem.implicitWidth + T.spaceM * 2
  padding: T.spaceS
  hoverEnabled: true
  contentItem: Item {
    id: content
    readonly property real sideWidth: Math.max(symbolText.visible ? symbolText.implicitWidth : 0, valueLabel.visible
                                               ? valueLabel.implicitWidth : 0)
    readonly property real labelInset: sideWidth > 0 ? sideWidth + T.spaceS : 0
    implicitWidth: label.visible ? label.implicitWidth + labelInset * 2 : sideWidth
    implicitHeight: Math.max(label.implicitHeight, symbolText.implicitHeight, valueLabel.implicitHeight)
    Text {
      id: symbolText
      visible: button.symbol.length > 0
      text: button.symbol
      anchors.left: label.visible ? parent.left : undefined
      anchors.horizontalCenter: label.visible ? undefined : parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      color: label.color
      font.family: button.symbolFamily
      font.pointSize: T.fontSizeB
    }
    Text {
      id: label
      visible: button.text.length > 0
      anchors {
        fill: parent
        leftMargin: content.labelInset
        rightMargin: content.labelInset
      }
      text: button.text
      color: !button.enabled || button.muted ? T.colM : button.selected || button.activeFocus ? T.colP : T.colF
      font.family: T.fontSans
      font.pointSize: T.fontSizeB
      font.bold: button.selected || button.activeFocus
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
    Text {
      id: valueLabel
      visible: button.valueText.length > 0
      anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
      }
      text: button.valueText
      color: label.color
      font.family: T.fontMono
      font.pointSize: T.fontSizeB
    }
  }
  background: Rectangle {
    color: button.selected || (button.enabled && (button.down || button.hovered)) ? T.colB : T.colO
  }
}
