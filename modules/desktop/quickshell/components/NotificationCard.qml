import QtQuick
import Quickshell
import ".."

Rectangle {
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

  implicitHeight: content.implicitHeight + T.dimS * 2
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
      margins: T.dimS
    }
    spacing: T.dimS

    Row {
      width: parent.width
      spacing: T.dimS

      Image {
        id: notificationImage
        width: 36
        height: 36
        visible: source.toString().length > 0
        source: card.imageSource()
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      Text {
        width: parent.width - (notificationImage.visible ? 36 + parent.spacing : 0)
        color: T.colF
        font.family: "sans-serif"
        font.pointSize: T.fontSizeM
        wrapMode: Text.Wrap
        textFormat: Text.RichText

        function escapeHeading(value) {
          return String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g,
                                                                                                          "<br>");
        }

        text: "<b>" + escapeHeading(card.notification?.appName ?? "") + "</b> - " + escapeHeading(card.notification
                                                                                                  ?.summary ?? "")
      }
    }

    Text {
      width: parent.width
      visible: text.length > 0
      color: T.colF
      font {
        family: "serif"
        pointSize: T.fontSizeM
      }
      wrapMode: Text.Wrap
      textFormat: Text.PlainText
      text: card.notification?.body ?? ""
    }
  }
}
