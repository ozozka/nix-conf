import QtQuick
import Quickshell
import Quickshell.Io
import "../components" as CM
import ".."

Scope {
  id: powerModule

  property string pendingAction: ""
  readonly property var entries: [
    {
      key: "lock",
      name: "⎋ Lock",
      command: ["qs", "ipc", "call", "lock", "lock"],
      destructive: false
    },
    {
      key: "monitors",
      name: "🆥 Monitors",
      command: ["hyprctl", "dispatch", "dpms", "off"],
      destructive: false
    },
    {
      key: "suspend",
      name: "⏾ Suspend",
      command: ["qs", "ipc", "call", "lock", "suspend"],
      destructive: false
    },
    {
      key: "logout",
      name: "⏎ Logout",
      command: ["hyprctl", "dispatch", "exit"],
      destructive: true
    },
    {
      key: "reboot",
      name: "⏼ Reboot",
      command: ["systemctl", "reboot"],
      destructive: true
    },
    {
      key: "shutdown",
      name: "⏻ Shutdown",
      command: ["systemctl", "poweroff"],
      destructive: true
    }
  ]

  required property var focusedScreen

  function open() {
    pendingAction = "";
    actions.currentIndex = 0;
    const targetScreen = focusedScreen;
    if (targetScreen)
      menu.screen = targetScreen;
    menu.visible = true;
    Qt.callLater(() => menu.focusMenu());
  }

  function close() {
    menu.visible = false;
    pendingAction = "";
  }

  function moveSelection(delta) {
    actions.currentIndex = (actions.currentIndex + delta + entries.length) % entries.length;
    actions.positionViewAtIndex(actions.currentIndex, ListView.Contain);
  }

  function activate(entry) {
    if (!entry)
      return;
    if (entry.destructive && pendingAction !== entry.key) {
      pendingAction = entry.key;
      return;
    }
    Quickshell.execDetached(entry.command);
    close();
  }

  IpcHandler {
    target: "power"

    function open(): void {
    powerModule.open();
  }
    function hide(): void {
                       powerModule.close();
                     }
    function toggle(): void {
    if (menu.visible)
    powerModule.close();
    else
    powerModule.open();
  }
  }

    CM.MenuWindow {
      id: menu
      namespace: "quickshell-power-menu"
      menuHeight: title.implicitHeight + T.spaceM * 3 + powerModule.entries.length * 42

      onKeyPressed: event => {
        if (event.key === Qt.Key_Escape) {
          powerModule.close();
          event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
          powerModule.moveSelection(1);
          event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
          powerModule.moveSelection(-1);
          event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
          if (!event.isAutoRepeat)
            powerModule.activate(powerModule.entries[actions.currentIndex]);
          event.accepted = true;
        }
      }

      Text {
        id: title
        anchors {
          top: parent.top
          left: parent.left
          margins: T.spaceM
        }
        color: T.colF
        font {
          family: T.fontMono
          pointSize: T.fontSizeH
          bold: true
        }
        text: "Power"
      }

      ListView {
        id: actions
        anchors {
          top: title.bottom
          left: parent.left
          right: parent.right
          bottom: parent.bottom
          margins: T.spaceM
        }
        model: powerModule.entries
        currentIndex: 0
        clip: true
        onCurrentIndexChanged: powerModule.pendingAction = ""

        delegate: Rectangle {
          required property var modelData
          required property int index
          width: actions.width
          height: 42
          color: ListView.isCurrentItem ? T.colO : "transparent"

          Text {
            anchors {
              left: parent.left
              right: parent.right
              verticalCenter: parent.verticalCenter
              margins: T.spaceM
            }
            color: T.colF
            font {
              family: T.fontMono
              pointSize: T.fontSizeB
            }
            text: powerModule.pendingAction === modelData.key ? `Confirm ${modelData.name}` : modelData.name
          }

          TapHandler {
            onTapped: {
              actions.currentIndex = index;
              powerModule.activate(modelData);
            }
          }
        }
      }
    }
  }
