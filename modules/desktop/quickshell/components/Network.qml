import QtQuick
import "../services" as SV
import "../lib" as LB
import ".."

Text {
  id: network

  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: SV.NetworkStats.connected ? `${LB.Units.formatRate(SV.NetworkStats.totalBytesPerSecond)}` : ""
}
