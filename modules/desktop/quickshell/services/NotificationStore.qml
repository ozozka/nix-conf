pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: store
  property var states: []
  signal promoted

  function promote(state) {
    states = [state, ...states.filter(candidate => candidate !== state)];
    promoted();
  }

  function remove(state) {
    states = states.filter(candidate => candidate !== state);
    Qt.callLater(() => state.destroy());
  }

  NotificationServer {
    keepOnReload: true
    persistenceSupported: true
    actionsSupported: true
    imageSupported: true
    onNotification: notification => {
      notification.tracked = true;
      const state = stateComponent.createObject(store, {
                                                  notification: notification
                                                });
      store.promote(state);
    }
  }

  Component {
    id: stateComponent
    QtObject {
      id: state
      required property var notification
      property bool refreshPending: false

      function refresh() {
        if (refreshPending)
          return;
        refreshPending = true;
        Qt.callLater(() => {
          state.refreshPending = false;
          if (state.notification && store.states.includes(state))
            store.promote(state);
        });
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
        function onUrgencyChanged() {
          state.refresh();
        }
        function onDesktopEntryChanged() {
          state.refresh();
        }
        function onHintsChanged() {
          state.refresh();
        }
        function onClosed() {
          store.remove(state);
        }
      }
    }
  }
}
