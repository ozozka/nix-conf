import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "../components" as CM
import ".."

Scope {
  id: launcherModule

  property string mode: "applications"
  property string pendingPowerAction: ""

  readonly property var powerEntries: [
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

  function focusedScreen() {
    const monitor = Hyprland.focusedMonitor;
    return Quickshell.screens.find(screen => Hyprland.monitorFor(screen) === monitor) ?? Quickshell.screens[0] ?? null;
  }

  function open(requestedMode) {
    if (!["applications", "power"].includes(requestedMode))
      return;
    mode = requestedMode;
    pendingPowerAction = "";
    search.text = "";
    results.currentIndex = 0;

    const targetScreen = focusedScreen();
    if (targetScreen)
      launcher.screen = targetScreen;

    launcher.visible = true;
    Qt.callLater(() => search.forceActiveFocus());
  }

  function close() {
    launcher.visible = false;
    pendingPowerAction = "";
    search.text = "";
  }

  function moveSelection(delta) {
    if (results.count === 0) {
      results.currentIndex = -1;
      return;
    }

    results.currentIndex = (results.currentIndex + delta + results.count) % results.count;
    results.positionViewAtIndex(results.currentIndex, ListView.Contain);
    pendingPowerAction = "";
  }

  function activate(entry) {
    if (!entry)
      return;
    if (mode === "applications") {
      entry.application.execute();
      close();
      return;
    }

    if (entry.destructive && pendingPowerAction !== entry.key) {
      pendingPowerAction = entry.key;
      return;
    }

    Quickshell.execDetached(entry.command);
    close();
  }

  IpcHandler {
    target: "launcher"

    function open(mode: string): void {
    launcherModule.open(mode);
  }
    function hide(): void {
                       launcherModule.close();
                     }
    function toggle(mode: string): void {
    if (launcher.visible)
    launcherModule.close();
    else
    launcherModule.open(mode);
  }
  }

    ScriptModel {
      id: resultModel
      objectProp: "key"
      values: {
        const query = search.text.trim().toLowerCase();
        let entries;

        if (launcherModule.mode === "applications") {
          entries = DesktopEntries.applications.values.map(application => ({
            key: `application-${application.id}`,
            name: application.name,
            detail: application.genericName || application.comment,
            icon: application.icon,
            application: application
          }));
        } else {
          entries = launcherModule.powerEntries;
        }

        return entries.filter(entry => !query || entry.name.toLowerCase().includes(query) || String(entry.detail
                                                                                                    || "").toLowerCase(
                                         ).includes(query)).slice(0, 50);
      }
    }

    PanelWindow {
      id: launcher

      visible: false
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-launcher"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      Item {
        anchors.fill: parent

        CM.Surface {
          id: surface
          anchors.top: parent.top
          anchors.topMargin: T.spaceM
          anchors.horizontalCenter: parent.horizontalCenter
          width: 480
          height: T.spaceL * 2 + Math.min(results.count, 6) * 42 + T.spaceM

          TextInput {
            id: search
            anchors {
              top: parent.top
              left: parent.left
              right: parent.right
              margins: T.spaceM
            }
            height: T.spaceL
            color: T.colF
            selectionColor: T.colP
            selectedTextColor: T.colO
            font {
              family: T.fontMono
              pointSize: T.fontSizeB
              bold: true
            }
            clip: true

            onTextChanged: {
              results.currentIndex = resultModel.values.length > 0 ? 0 : -1;
              launcherModule.pendingPowerAction = "";
            }

            onAccepted: launcherModule.activate(results.currentItem?.entry)

            Keys.onPressed: event => {
              if (event.key === Qt.Key_Escape) {
                launcherModule.close();
                event.accepted = true;
              } else if (event.key === Qt.Key_Down) {
                launcherModule.moveSelection(1);
                event.accepted = true;
              } else if (event.key === Qt.Key_Up) {
                launcherModule.moveSelection(-1);
                event.accepted = true;
              }
            }
          }

          ListView {
            id: results
            anchors {
              top: search.bottom
              topMargin: T.spaceS
              left: parent.left
              right: parent.right
              bottom: parent.bottom
              margins: T.spaceS
            }
            clip: true
            spacing: 0
            model: resultModel
            currentIndex: count > 0 ? 0 : -1

            onCountChanged: {
              if (count === 0)
                currentIndex = -1;
              else if (currentIndex < 0 || currentIndex >= count)
                currentIndex = 0;
            }

            delegate: Rectangle {
              id: resultItem
              required property var modelData
              property var entry: modelData

              width: results.width
              height: 42
              radius: T.spaceS
              color: ListView.isCurrentItem ? T.colO : "transparent"

              IconImage {
                anchors {
                  left: parent.left
                  leftMargin: T.spaceM
                  verticalCenter: parent.verticalCenter
                }
                width: T.spaceL
                height: T.spaceL
                visible: !!resultItem.entry.application
                source: Quickshell.iconPath(resultItem.entry.icon || "application-x-executable", "")
              }

              Text {
                anchors {
                  left: parent.left
                  right: parent.right
                  verticalCenter: parent.verticalCenter
                  margins: T.spaceM
                  leftMargin: resultItem.entry.application ? T.spaceM * 2 + T.spaceL : T.spaceM
                }
                color: T.colF
                font {
                  family: T.fontMono
                  pointSize: T.fontSizeB
                }
                elide: Text.ElideRight
                text: launcherModule.pendingPowerAction === resultItem.entry.key ? `Confirm ${resultItem.entry.name}` :
                                                                                   resultItem.entry.name
              }

              TapHandler {
                onTapped: {
                  launcherModule.activate(resultItem.entry);
                }
              }
            }
          }
        }
      }
    }
  }
