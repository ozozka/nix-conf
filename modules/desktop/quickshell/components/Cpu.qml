import QtQuick
import "../services" as SV
import ".."

Text {
  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: `${SV.CpuStats.usage.toFixed(2)}%`
}
