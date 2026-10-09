import QtQuick
import QtQuick.Controls
import ".."

Button {
  id: button
  property bool selected: false
  property string symbol: ""
  property string symbolFamily: "monospace"
  property string valueText: ""
  property bool muted: false
  implicitHeight: T.dimM + T.dimS
  implicitWidth: contentItem.implicitWidth + T.dimS * 2
  padding: T.dimS
  hoverEnabled: true
  contentItem: Item {
    id: content
    readonly property real sideWidth: Math.max(symbolText.visible ? symbolText.implicitWidth : 0, valueLabel.visible
                                               ? valueLabel.implicitWidth : 0)
    readonly property real labelInset: sideWidth > 0 ? sideWidth + T.dimS : 0
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
      font.pointSize: T.fontSizeM
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
      font.family: "sans-serif"
      font.pointSize: T.fontSizeM
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
      font.family: "monospace"
      font.pointSize: T.fontSizeM
    }
  }
  background: Rectangle {
    color: button.selected || (button.enabled && (button.down || button.hovered)) ? T.colB : T.colO
  }
}
