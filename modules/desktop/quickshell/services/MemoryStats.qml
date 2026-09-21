pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: memory

  property real usedBytes: 0
  property real totalBytes: 0

  function update(text) {
    const values = {};
    for (const line of text.split("\n")) {
      const match = line.match(/^(MemTotal|MemAvailable):\s+(\d+)/);
      if (match)
        values[match[1]] = Number(match[2]) * 1024;
    }

    if (values.MemTotal && values.MemAvailable !== undefined) {
      totalBytes = values.MemTotal;
      usedBytes = values.MemTotal - values.MemAvailable;
    }
  }

  FileView {
    id: meminfoFile
    path: "/proc/meminfo"
    onLoaded: memory.update(text())
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: meminfoFile.reload()
  }
}
