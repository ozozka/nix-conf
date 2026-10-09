import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components" as CM
import "../services" as SV
import ".."

Scope {
  id: menuModule
  required property var focusedScreen
  property string pendingAction: ""
  readonly property bool powerExpanded: controls.expanded === "power"
  readonly property var powerEntries: [
    {
      key: "lock",
      symbol: "⎋",
      name: "Lock",
      command: ["qs", "ipc", "call", "lock", "lock"],
      destructive: false
    },
    {
      key: "monitors",
      symbol: "🆥",
      name: "Monitors off",
      command: ["hyprctl", "dispatch", "dpms", "off"],
      destructive: false
    },
    {
      key: "suspend",
      symbol: "⏾",
      name: "Suspend",
      command: ["qs", "ipc", "call", "lock", "suspend"],
      destructive: false
    },
    {
      key: "logout",
      symbol: "⏎",
      name: "Logout",
      command: ["hyprctl", "dispatch", "exit"],
      destructive: true
    },
    {
      key: "reboot",
      symbol: "⏼",
      name: "Reboot",
      command: ["systemctl", "reboot"],
      destructive: true
    },
    {
      key: "shutdown",
      symbol: "⏻",
      name: "Shutdown",
      command: ["systemctl", "poweroff"],
      destructive: true
    }
  ]

  function dismissSelection() {
    pendingAction = "";
    controls.reset();
    applications.focusSearch();
  }

  function togglePower() {
    controls.toggleDetails("power", powerButton);
  }

  function open() {
    pendingAction = "";
    controls.reset();
    if (focusedScreen)
      panel.screen = focusedScreen;
    panel.visible = true;
    SV.PowerProfiles.refresh();
    Qt.callLater(() => {
      applications.resetAndFocus();
      const bottom = applications.mapToItem(content, 0, applications.height).y;
      scroll.contentY = Math.max(0, Math.min(scroll.contentHeight - scroll.height, bottom - scroll.height));
    });
  }

  function close() {
    panel.visible = false;
    pendingAction = "";
    applications.query = "";
    controls.reset();
  }

  function activatePower(entry) {
    if (entry.destructive && pendingAction !== entry.key) {
      pendingAction = entry.key;
      return;
    }
    Quickshell.execDetached(entry.command);
    close();
  }

  Component {
    id: powerDetails
    ColumnLayout {
      spacing: T.spaceS
      Repeater {
        model: menuModule.powerEntries
        CM.MenuButton {
          required property var modelData
          Layout.fillWidth: true
          symbol: modelData.symbol
          text: menuModule.pendingAction === modelData.key ? `Confirm ${modelData.name}` : modelData.name
          selected: menuModule.pendingAction === modelData.key
          onClicked: menuModule.activatePower(modelData)
        }
      }
    }
  }

  IpcHandler {
    target: "menu"
    function open(): void {
    menuModule.open();
  }
    function hide(): void {
                       menuModule.close();
                     }
    function toggle(): void {
    if (panel.visible)
    menuModule.close();
    else
    menuModule.open();
  }
  }

    CM.MenuWindow {
      id: panel
      menuWidth: Math.min(980, width - T.spaceM * 2)
      menuHeight: Math.min(content.height + T.spaceM * 2, Math.max(0, height - T.spaceL - T.spaceM * 2))
      onDismissRequested: menuModule.close()
      widgetContent: CM.SelectionWidget {
        id: selection
        menuWindow: panel
        visible: panel.visible && controls.expanded !== ""
        anchorItem: controls.selectionAnchor
        title: menuModule.powerExpanded ? "Power actions" : ({
                                                               wifi: "Wi-Fi",
                                                               bluetooth: "Bluetooth",
                                                               profiles: "Power profile",
                                                               output: "Speaker",
                                                               input: "Microphone"
                                                             })[controls.expanded] ?? ""
        content: menuModule.powerExpanded ? powerDetails : controls.details
      }
      onKeyPressed: event => {
        if (event.key === Qt.Key_Escape) {
          if (selection.visible) {
            menuModule.dismissSelection();
          } else {
            menuModule.close();
          }
          event.accepted = true;
        }
      }

      Flickable {
        id: scroll
        anchors {
          fill: parent
          margins: T.spaceM
        }
        contentHeight: content.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        GridLayout {
          id: content
          width: scroll.width
          readonly property real controlsHeight: controls.implicitHeight + footer.implicitHeight + T.spaceM
          height: columns === 2 ? Math.max(controlsHeight, applications.implicitHeight) : controlsHeight
                                  + applications.implicitHeight + T.spaceM
          columns: width < 760 ? 1 : 2
          columnSpacing: T.spaceM
          rowSpacing: T.spaceM

          ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            Layout.preferredWidth: 1
            Layout.preferredHeight: content.controlsHeight
            Layout.minimumWidth: 0
            spacing: T.spaceM

            Flickable {
              id: controlsScroll
              Layout.fillWidth: true
              Layout.preferredHeight: controls.implicitHeight
              Layout.minimumHeight: 0
              contentHeight: controls.implicitHeight
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              CM.SystemControls {
                id: controls
                width: controlsScroll.width
                height: implicitHeight
                active: panel.visible
                onDetailsRequested: {
                  menuModule.pendingAction = "";
                  if (expanded)
                    Qt.callLater(() => selection.forceActiveFocus());
                  else
                    applications.focusSearch();
                }
              }
            }

            RowLayout {
              id: footer
              Layout.fillWidth: true
              spacing: T.spaceM
              CM.MenuButton {
                id: powerButton
                symbol: "⏻"
                Accessible.name: "Power actions"
                selected: menuModule.powerExpanded
                onClicked: menuModule.togglePower()
              }
              Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: `▰ ${Math.round(SV.BatteryStats.percentage)}% · ${SV.BatteryStats.status}`
                color: T.colM
                font.family: "sans-serif"
                font.pointSize: T.fontSizeB
                elide: Text.ElideRight
              }
              Row {
                spacing: T.spaceS
                Text {
                  text: "⌨"
                  color: T.colM
                  font.family: "monospace"
                  font.pointSize: T.fontSizeB
                }
                CM.Language {
                  font.family: "sans-serif"
                  color: T.colM
                }
              }
            }
          }

          CM.ApplicationSearch {
            id: applications
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.preferredHeight: implicitHeight
            onLaunched: menuModule.close()
            onQueryChanged: menuModule.pendingAction = ""
          }
        }
      }
    }
  }
