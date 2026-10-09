import QtQuick
import "../services" as SV
import ".."

Text {
  color: T.colF
  font {
    family: "monospace"
    pointSize: T.fontSizeM
  }
  text: `${SV.CpuStats.usage.toFixed(2)}%`
}
