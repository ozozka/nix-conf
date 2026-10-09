import QtQuick
import Quickshell
import ".."

Surface {
  id: card

  required property var notificationState
  readonly property var notification: notificationState?.notification ?? null

  function imageSource() {
    if (!notification)
      return "";
    if (String(notification.image || "").length > 0)
      return notification.image;
    if (notification.appIcon.length > 0)
      return Quickshell.iconPath(notification.appIcon, "");
    return "";
  }

  implicitHeight: content.implicitHeight + T.spaceM + T.spaceS
  color: cardHover.hovered ? T.colB : T.colO
  HoverHandler {
    id: cardHover
  }

  TapHandler {
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onTapped: (eventPoint, button) => {
      if (!card.notification)
        return;
      if (button === Qt.RightButton) {
        card.notification.dismiss();
      } else {
        const actions = card.notification.actions;
        const action = actions.find(action => action.identifier === "default") ?? actions[0];
        if (action) {
          const resident = card.notification.resident;
          action.invoke();
          if (resident && card.notification)
            card.notification.dismiss();
        } else {
          card.notification.dismiss();
        }
      }
    }
  }

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
        width: parent.width - (notificationImage.visible ? 36 + parent.spacing : 0)
        spacing: 2

        Text {
          width: parent.width
          color: T.colM
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
          }
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: card.notification?.appName ?? ""
        }

        Text {
          width: parent.width
          color: T.colF
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
            bold: true
          }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          text: card.notification?.summary ?? ""
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
      text: card.notification?.body ?? ""
    }
  }
}
