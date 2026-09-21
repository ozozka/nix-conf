pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: battery

  property real percentage: 0
  property string status: "Unknown"
  property real energy: 0
  property real fullEnergy: 0
  property real power: 0

  readonly property real remainingSeconds: {
    if (power <= 0)
      return 0;
    const remainingEnergy = status === "Charging" ? fullEnergy - energy : energy;
    return Math.max(0, 3600 * remainingEnergy / power);
  }

  function updateNumber(file, propertyName) {
    const value = Number(file.text().trim());
    if (!Number.isNaN(value))
      battery[propertyName] = value;
  }

  FileView {
    id: capacityFile
    path: "/sys/class/power_supply/BAT1/capacity"
    onLoaded: battery.updateNumber(this, "percentage")
  }

  FileView {
    id: statusFile
    path: "/sys/class/power_supply/BAT1/status"
    onLoaded: battery.status = text().trim()
  }

  FileView {
    id: energyFile
    path: "/sys/class/power_supply/BAT1/energy_now"
    onLoaded: battery.updateNumber(this, "energy")
  }

  FileView {
    id: fullEnergyFile
    path: "/sys/class/power_supply/BAT1/energy_full"
    onLoaded: battery.updateNumber(this, "fullEnergy")
  }

  FileView {
    id: powerFile
    path: "/sys/class/power_supply/BAT1/power_now"
    onLoaded: battery.updateNumber(this, "power")
  }

  Timer {
    interval: 600
    running: true
    repeat: true
    onTriggered: {
      capacityFile.reload();
      statusFile.reload();
      energyFile.reload();
      fullEnergyFile.reload();
      powerFile.reload();
    }
  }
}
