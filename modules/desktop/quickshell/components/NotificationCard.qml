import QtQuick
import Quickshell
import QtQuick.Layouts
import ".."

Surface {
  id: card

  required property var notificationState
  readonly property var notification: notificationState.notification

  function imageSource() {
    if (String(notification.image || "").length > 0)
      return notification.image;
    if (notification.appIcon.length > 0)
      return Quickshell.iconPath(notification.appIcon, "");
    return "";
  }

  implicitHeight: content.implicitHeight + T.spaceM * 2

  Column {
    id: content
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: T.spaceM
    }
    spacing: T.spaceS

    Row {
      width: parent.width
      spacing: T.spaceM

      Image {
        id: notificationImage
        width: 36
        height: 36
        visible: source.toString().length > 0
        source: card.imageSource()
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      Column {
        width: parent.width - (notificationImage.visible ? 36 + parent.spacing : 0) - closeButton.width
        spacing: 2

        Text {
          width: parent.width
          color: T.colM
          font {
            family: T.fontMono
            pointSize: T.fontSizeB
          }
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: card.notification.appName
        }

        Text {
          width: parent.width
          color: T.colF
          font {
            family: T.fontMono
            pointSize: T.fontSizeB
            bold: true
          }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          text: card.notification.summary
        }
      }

      Text {
        id: closeButton
        width: T.spaceL
        color: T.colM
        font {
          family: T.fontMono
          pointSize: T.fontSizeB
          bold: true
        }
        horizontalAlignment: Text.AlignHCenter
        text: "x"

        TapHandler {
          onTapped: card.notification.dismiss()
        }
      }
    }

    Text {
      width: parent.width
      visible: text.length > 0
      color: T.colF
      font {
        family: T.fontSans
        pointSize: T.fontSizeB
      }
      wrapMode: Text.Wrap
      textFormat: Text.PlainText
      text: card.notification.body
    }

    Row {
      width: parent.width
      spacing: T.spaceS
      visible: card.notification.actions.length > 0

      Repeater {
        model: card.notification.actions

        Rectangle {
          required property var modelData
          width: actionText.implicitWidth + T.spaceM * 2
          height: T.spaceL
          radius: T.spaceS
          color: T.colO

          Text {
            id: actionText
            anchors.centerIn: parent
            color: T.colF
            font {
              family: T.fontMono
              pointSize: T.fontSizeB
            }
            textFormat: Text.PlainText
            text: modelData.text
          }

          TapHandler {
            onTapped: modelData.invoke()
          }
        }
      }
    }
  }
}
