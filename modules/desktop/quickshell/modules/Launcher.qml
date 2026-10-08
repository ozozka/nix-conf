import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../components" as CM
import ".."

Scope {
  id: launcherModule

  required property var focusedScreen

  function open() {
    search.text = "";
    results.currentIndex = 0;

    const targetScreen = focusedScreen;
    if (targetScreen)
      launcher.screen = targetScreen;

    launcher.visible = true;
    Qt.callLater(() => search.forceActiveFocus());
  }

  function close() {
    launcher.visible = false;
    search.text = "";
  }

  function moveSelection(delta) {
    if (results.count === 0) {
      results.currentIndex = -1;
      return;
    }

    results.currentIndex = (results.currentIndex + delta + results.count) % results.count;
    results.positionViewAtIndex(results.currentIndex, ListView.Contain);
  }

  function activate(entry) {
    if (!entry)
      return;
    // Quickshell IDs omit .desktop; gtk-launch resolves the entry in its own systemd unit.
    Quickshell.execDetached(["systemd-run", "--user", "--collect", "--slice=app.slice", "--property=Type=exec",
                             "--property=ExitType=cgroup", "--property=PartOf=graphical-session.target",
                             "--property=After=graphical-session.target", `--property=WorkingDirectory=${Quickshell.env(
                               "HOME")}`, "--", "gtk-launch", `${entry.application.id}.desktop`]);
    close();
  }

  IpcHandler {
    target: "launcher"

    function open(): void {
    launcherModule.open();
  }
    function hide(): void {
                       launcherModule.close();
                     }
    function toggle(): void {
    if (launcher.visible)
    launcherModule.close();
    else
    launcherModule.open();
  }
  }

    ScriptModel {
      id: resultModel
      objectProp: "key"
      values: {
        const query = search.text.trim().toLowerCase();
        const entries = DesktopEntries.applications.values.map(application => ({
          key: `application-${application.id}`,
          name: application.name,
          detail: application.genericName || application.comment,
          icon: application.icon,
          application: application
        }));

        return entries.filter(entry => !query || entry.name.toLowerCase().includes(query) || String(entry.detail
                                                                                                    || "").toLowerCase(
                                         ).includes(query)).slice(0, 50);
      }
    }

    CM.MenuWindow {
      id: launcher
      namespace: "quickshell-launcher"
      menuHeight: T.spaceL * 2 + Math.min(results.count, 6) * 42 + T.spaceM

      TextInput {
        id: search
        anchors {
          bottom: parent.bottom
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
          top: parent.top
          left: parent.left
          right: parent.right
          bottom: search.top
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
          color: ListView.isCurrentItem ? T.colO : "transparent"

          IconImage {
            anchors {
              left: parent.left
              leftMargin: T.spaceM
              verticalCenter: parent.verticalCenter
            }
            width: T.spaceL
            height: T.spaceL
            source: Quickshell.iconPath(resultItem.entry.icon || "application-x-executable", "")
          }

          Text {
            anchors {
              left: parent.left
              right: parent.right
              verticalCenter: parent.verticalCenter
              margins: T.spaceM
              leftMargin: T.spaceM * 2 + T.spaceL
            }
            color: T.colF
            font {
              family: T.fontMono
              pointSize: T.fontSizeB
            }
            elide: Text.ElideRight
            text: resultItem.entry.name
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
