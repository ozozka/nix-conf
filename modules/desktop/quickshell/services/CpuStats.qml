pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: cpu

  property real usage: 0
  property double previousTotal: 0
  property double previousIdle: 0

  function update(text) {
    const line = text.split("\n").find(line => line.startsWith("cpu "));
    if (!line)
      return;
    const values = line.trim().split(/\s+/).slice(1).map(Number);
    const total = values.reduce((sum, value) => sum + value, 0);
    const idle = values[3] + values[4];

    if (previousTotal > 0) {
      const totalDelta = total - previousTotal;
      const idleDelta = idle - previousIdle;
      if (totalDelta > 0)
        usage = 100 * (totalDelta - idleDelta) / totalDelta;
    }

    previousTotal = total;
    previousIdle = idle;
  }

  FileView {
    id: statFile
    path: "/proc/stat"
    onLoaded: cpu.update(text())
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: statFile.reload()
  }
}
