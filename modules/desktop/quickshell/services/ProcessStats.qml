pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: processes
  property int count: 0

  Process {
    id: snapshot
    // One PID per process, not one entry per thread or cumulative forks.
    command: ["ps", "-e", "-o", "pid="]
    running: true
    stdout: StdioCollector {
      onStreamFinished: processes.count = text.trim() ? text.trim().split(/\s+/).length : 0
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      if (!snapshot.running)
        snapshot.running = true;
    }
  }
}
