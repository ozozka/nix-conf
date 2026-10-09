pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: profiles
  property bool backendPresent: false
  readonly property var availableProfiles: backend.item?.availableProfiles ?? []
  readonly property string activeProfile: backend.item?.activeProfile ?? ""
  readonly property bool available: (backend.item?.available ?? false) && availableProfiles.length > 0
  readonly property string error: backend.item?.error ?? ""
  readonly property bool busy: backend.item?.busy ?? false

  function refresh() {
    if (!probe.running)
      probe.running = true;
    backend.item?.refresh();
  }

  function setProfile(profile) {
    backend.item?.setProfile(profile);
  }

  // Check owned bus names, not activatable services: opening the menu must not start PPD.
  Process {
    id: probe
    command: ["sh", "-c",
      "command -v powerprofilesctl >/dev/null 2>&1 && exec busctl --system --acquired --no-pager --no-legend list"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: profiles.backendPresent =
                        /^(net\.hadess\.PowerProfiles|org\.freedesktop\.UPower\.PowerProfiles)\s/m.test(text)
    }
    onExited: (code, status) => {
      if (code !== 0 || status !== 0)
        profiles.backendPresent = false;
    }
  }
  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: {
      if (!probe.running)
        probe.running = true;
    }
  }

  Loader {
    id: backend
    active: profiles.backendPresent
    sourceComponent: Component {
      Scope {
        id: controller
        property var availableProfiles: []
        property string activeProfile: ""
        property bool available: false
        property string error: ""
        readonly property bool busy: setProcess.running

        function refresh() {
          if (!setProcess.running && !listProcess.running && !getProcess.running) {
            listProcess.running = true;
            getProcess.running = true;
          }
        }

        function setProfile(profile) {
          if (!available || busy || !availableProfiles.includes(profile) || profile === activeProfile)
            return;
          error = "";
          setProcess.command = ["powerprofilesctl", "set", profile];
          setProcess.running = true;
        }

        Component.onCompleted: refresh()
        Timer {
          interval: 10000
          running: true
          repeat: true
          onTriggered: controller.refresh()
        }

        Process {
          id: listProcess
          command: ["powerprofilesctl", "list"]
          stdout: StdioCollector {
            onStreamFinished: {
              const expression = /^\s*\*?\s*(power-saver|balanced|performance):/gm;
              const result = [];
              let match;
              while ((match = expression.exec(text)) !== null)
                result.push(match[1]);
              controller.availableProfiles = result;
            }
          }
          onExited: (code, status) => {
            if (code !== 0 || status !== 0) {
              controller.available = false;
              controller.availableProfiles = [];
            }
          }
        }
        Process {
          id: getProcess
          command: ["powerprofilesctl", "get"]
          stdout: StdioCollector {
            onStreamFinished: controller.activeProfile = text.trim()
          }
          onExited: (code, status) => controller.available = code === 0 && status === 0
                                      && controller.activeProfile.length > 0
        }
        Process {
          id: setProcess
          property string failure: ""
          onStarted: failure = ""
          stderr: StdioCollector {
            onStreamFinished: setProcess.failure = text.trim()
          }
          onExited: (code, status) => {
            if (code !== 0 || status !== 0)
              controller.error = failure || "Could not change the power profile.";
            controller.refresh();
          }
        }
      }
    }
  }
}
