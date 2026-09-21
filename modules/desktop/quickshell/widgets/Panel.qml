import Quickshell
import Quickshell.Wayland
import QtQuick
import ".."

PanelWindow {
  id: root

  color: T.colB

  BackgroundEffect.blurRegion: Region {
    item: root.contentItem
  }
}
