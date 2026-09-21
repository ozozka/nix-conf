import QtQuick
import "../services" as SV
import ".."

Text {
  id: battery

  readonly property bool charging: SV.BatteryStats.status === "Charging"
  readonly property bool full: SV.BatteryStats.status === "Full"

  function formatRemaining(seconds) {
    if (seconds <= 0)
      return "";
    return `${String(Math.floor(seconds / 60))}m`;
  }

  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: full ? "🞄" : `${formatRemaining(SV.BatteryStats.remainingSeconds)} ${Math.round(SV.BatteryStats.percentage)}
${charging ? "🞄" : "◦"}`
}
