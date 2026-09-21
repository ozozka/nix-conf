pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: temperature

  property real celsius: 0

  FileView {
    id: temperatureFile
    path: "/sys/class/thermal/thermal_zone3/temp"
    onLoaded: {
      const millidegrees = Number(text().trim());
      if (!Number.isNaN(millidegrees))
        temperature.celsius = millidegrees / 1000;
    }
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: temperatureFile.reload()
  }
}
