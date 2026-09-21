import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import "../components" as CM
import ".."

Scope {
  id: notificationModule

  property var states: []

  function focusedScreen() {
    const monitor = Hyprland.focusedMonitor;
    return Quickshell.screens.find(screen => Hyprland.monitorFor(screen) === monitor) ?? Quickshell.screens[0] ?? null;
  }

  function enforcePopupLimit() {
    const visibleStates = states.filter(state => state.popupVisible);
    for (let index = 6; index < visibleStates.length; ++index) {
      const state = visibleStates[index];
      state.popupVisible = false;
      if (state.notification.transient)
        state.notification.expire();
    }
  }

  function enforceHistoryLimit() {
    const historyStates = states.filter(state => !state.notification.transient);
    for (let index = 100; index < historyStates.length; ++index)
      historyStates[index].notification.dismiss();
  }

  function promote(state) {
    state.popupVisible = true;
    states = [state, ...states.filter(candidate => candidate !== state)];
    const targetScreen = focusedScreen();
    if (targetScreen)
      popupWindow.screen = targetScreen;
    enforcePopupLimit();
  }

  function remove(state) {
    states = states.filter(candidate => candidate !== state);
    Qt.callLater(() => state.destroy());
  }

  function clearHistory() {
    [...states].filter(state => !state.notification.transient).forEach(state => state.notification.dismiss());
  }

  function setHistoryVisible(visible) {
    if (visible) {
      const targetScreen = focusedScreen();
      if (targetScreen)
        historyWindow.screen = targetScreen;
    }
    historyWindow.visible = visible;
    if (visible)
      Qt.callLater(() => historyFocus.forceActiveFocus());
  }

  NotificationServer {
    id: server
    keepOnReload: true
    persistenceSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: notification => {
      notification.tracked = true;
      if (notification.lastGeneration && notification.transient) {
        notification.expire();
        return;
      }
      const state = stateComponent.createObject(notificationModule, {
                                                  notification: notification,
                                                  popupVisible: !notification.lastGeneration
                                                });
      notificationModule.states = [state, ...notificationModule.states];
      notificationModule.enforceHistoryLimit();
      if (state.popupVisible)
        notificationModule.promote(state);
    }
  }

  Component {
    id: stateComponent

    QtObject {
      id: state
      required property var notification
      property bool popupVisible: false

      function refresh() {
        Qt.callLater(() => {
          if (!state.notification)
            return;
          notificationModule.promote(state);
          popupTimer.restart();
        });
      }

      property Timer popupTimer: Timer {
        interval: state.notification?.expireTimeout > 0 ? state.notification.expireTimeout : 12000
        running: state.popupVisible && state.notification?.expireTimeout !== 0
        repeat: false
        onTriggered: {
          state.popupVisible = false;
          if (state.notification.transient)
            state.notification.expire();
        }
      }

      property Connections notificationConnections: Connections {
        target: state.notification

        function onSummaryChanged() {
          state.refresh();
        }
        function onBodyChanged() {
          state.refresh();
        }
        function onAppNameChanged() {
          state.refresh();
        }
        function onImageChanged() {
          state.refresh();
        }
        function onAppIconChanged() {
          state.refresh();
        }
        function onActionsChanged() {
          state.refresh();
        }
        function onExpireTimeoutChanged() {
          state.refresh();
        }
        function onUrgencyChanged() {
          state.refresh();
        }
        function onTransientChanged() {
          state.refresh();
        }
        function onResidentChanged() {
          state.refresh();
        }
        function onDesktopEntryChanged() {
          state.refresh();
        }
        function onHintsChanged() {
          state.refresh();
        }
        function onClosed() {
          notificationModule.remove(state);
        }
      }
    }
  }

  ScriptModel {
    id: popupModel
    values: notificationModule.states.filter(state => state.popupVisible).slice(0, 6)
  }

  ScriptModel {
    id: historyModel
    values: notificationModule.states.filter(state => !state.notification.transient)
  }

  IpcHandler {
    target: "notifications"

    function open(): void {
    notificationModule.setHistoryVisible(true);
  }
    function hide(): void {
                       notificationModule.setHistoryVisible(false);
                     }
    function toggle(): void {
    notificationModule.setHistoryVisible(!historyWindow.visible);
  }
    function clear(): void {
                        notificationModule.clearHistory();
                      }
  }

  PanelWindow {
    id: popupWindow

    visible: popupModel.values.length > 0
    color: "transparent"
    implicitWidth: 444
    implicitHeight: Math.min(popupColumn.implicitHeight + T.spaceM * 2, screen?.height ?? 1080)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
      top: true
      right: true
    }

    Column {
      id: popupColumn
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: T.spaceM
      }
      spacing: T.spaceS

      Repeater {
        model: popupModel

        CM.NotificationCard {
          required property var modelData
          width: popupColumn.width
          notificationState: modelData
        }
      }
    }
  }

  PanelWindow {
    id: historyWindow

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell-notification-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    FocusScope {
      id: historyFocus
      anchors.fill: parent

      Keys.onEscapePressed: notificationModule.setHistoryVisible(false)

      CM.Surface {
        anchors.centerIn: parent
        width: 480
        height: Math.min(640, parent.height - T.spaceL * 2)

        Text {
          id: historyTitle
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
          text: "Notifications"
        }

        Text {
          anchors {
            top: parent.top
            right: clearButton.left
            margins: T.spaceM
          }
          color: T.colM
          font {
            family: T.fontMono
            pointSize: T.fontSizeB
          }
          text: "close"
          TapHandler {
            onTapped: notificationModule.setHistoryVisible(false)
          }
        }

        Text {
          id: clearButton
          anchors {
            top: parent.top
            right: parent.right
            margins: T.spaceM
          }
          color: T.colM
          font {
            family: T.fontMono
            pointSize: T.fontSizeB
          }
          text: "clear"
          TapHandler {
            onTapped: notificationModule.clearHistory()
          }
        }

        ListView {
          anchors {
            top: historyTitle.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: T.spaceM
          }
          spacing: T.spaceS
          clip: true
          model: historyModel

          delegate: CM.NotificationCard {
            required property var modelData
            width: ListView.view.width
            notificationState: modelData
          }
        }
      }
    }
  }
}
