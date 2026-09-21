import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import ".."

Text {
  id: language

  property string layout: ""

  function updateLayout(devices) {
    const keyboard = devices.keyboards.find(keyboard => keyboard.main);
    if (!keyboard)
      return;
    const layouts = keyboard.layout.split(",");
    layout = layouts[keyboard.active_layout_index] || keyboard.active_keymap;
  }

  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: layout

  Process {
    id: devicesProcess
    command: ["hyprctl", "-j", "devices"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          language.updateLayout(JSON.parse(this.text));
        } catch (error) {
          console.warn(`Failed to read keyboard layout: ${error}`);
        }
      }
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "activelayout")
        devicesProcess.running = true;
    }
  }
}
