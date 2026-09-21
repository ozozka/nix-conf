import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import ".."

Text {
  id: submapDisplay

  property string submap: "default"

  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: submap
  visible: submap !== "default" && submap !== ""

  Process {
    id: submapProcess
    command: ["hyprctl", "submap"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: submapDisplay.submap = this.text.trim()
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "submap")
        submapDisplay.submap = event.data || "default";
    }
  }
}
