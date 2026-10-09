import QtQuick
import "../services" as SV
import ".."

Text {
  color: T.colF
  font {
    family: "monospace"
    pointSize: T.fontSizeM
  }
  text: `${Math.round(SV.TemperatureStats.celsius)}°C`
}
