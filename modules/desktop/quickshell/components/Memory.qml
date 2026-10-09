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
    pointSize: T.fontSizeB
  }
  text: units.formatBytes(SV.MemoryStats.usedBytes)
}
