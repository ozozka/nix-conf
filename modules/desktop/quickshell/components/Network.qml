import QtQuick
import "../services" as SV
import "../lib" as LB
import ".."

Text {
  LB.Units {
    id: units
  }

  color: T.colF
  font {
    family: "monospace"
    pointSize: T.fontSizeM
  }
  text: SV.NetworkStats.connected ? `${units.formatRate(SV.NetworkStats.totalBytesPerSecond)}` : ""
}
