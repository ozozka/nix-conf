import Quickshell
import QtQuick
import Quickshell.Wayland
import "modules" as MD

ShellRoot {
  MD.Bar {}
  MD.Launcher {}
  MD.Notification {}
  MD.Polkit {}
  MD.Lock {}
  MD.Wallpaper {}
}
