import QtQuick
import "../services" as SV
import ".."

Text {
  color: T.colF
  font {
    family: "monospace"
    pointSize: T.fontSizeM
  }
  text: `${SV.ProcessStats.count}p`
  Accessible.name: `${SV.ProcessStats.count} processes`
}
