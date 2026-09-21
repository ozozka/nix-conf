import QtQuick
import "../services" as SV
import "../lib" as LB
import ".."

Text {
  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: LB.Units.formatBytes(SV.MemoryStats.usedBytes)
}
