import Quickshell
import QtQuick
import Quickshell.Hyprland
import "modules" as MD

ShellRoot {
  id: root

  readonly property var focusedScreen: {
    const monitor = Hyprland.focusedMonitor;
    return Quickshell.screens.find(screen => Hyprland.monitorFor(screen) === monitor) ?? Quickshell.screens[0] ?? null;
  }

  MD.Bar {}
  MD.Launcher {
    focusedScreen: root.focusedScreen
  }
  MD.PowerMenu {
    focusedScreen: root.focusedScreen
  }
  MD.Notification {
    focusedScreen: root.focusedScreen
  }
  MD.Polkit {}
  MD.Lock {}
  MD.Wallpaper {}
}
