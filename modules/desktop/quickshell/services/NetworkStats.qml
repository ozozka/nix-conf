pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
  id: network

  property string interfaceName: "wlan0"
  property real downloadBytesPerSecond: 0
  property real uploadBytesPerSecond: 0
  property real totalBytesPerSecond: 0
  property double previousReceived: 0
  property double previousTransmitted: 0
  property double previousTime: 0

  readonly property var device: Networking.devices.values.find(device => device.name === interfaceName)
  readonly property bool connected: device?.connected ?? false

  function update(text) {
    const line = text.split("\n").find(line => line.trim().startsWith(`${interfaceName}:`));
    if (!line)
      return;
    const values = line.replace(/.*:\s*/, "").trim().split(/\s+/).map(Number);
    const received = values[0];
    const transmitted = values[8];
    const now = Date.now();

    if (previousTime > 0) {
      const elapsedSeconds = (now - previousTime) / 1000;
      if (elapsedSeconds > 0) {
        downloadBytesPerSecond = Math.max(0, (received - previousReceived) / elapsedSeconds);
        uploadBytesPerSecond = Math.max(0, (transmitted - previousTransmitted) / elapsedSeconds);
        totalBytesPerSecond = downloadBytesPerSecond + uploadBytesPerSecond;
      }
    }

    previousReceived = received;
    previousTransmitted = transmitted;
    previousTime = now;
  }

  FileView {
    id: networkFile
    path: "/proc/net/dev"
    onLoaded: network.update(text())
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: networkFile.reload()
  }
}
