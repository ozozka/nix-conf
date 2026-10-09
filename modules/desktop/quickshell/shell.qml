import Quickshell

ShellRoot {
  id: root

  property T theme: T {}
  property Lib lib: Lib {}

  Bar {
    theme: root.theme
    lib: root.lib
  }
  Menu {
    theme: root.theme
    lib: root.lib
    focusedScreen: root.lib.focusedScreen
  }
  Notification {
    theme: root.theme
    focusedScreen: root.lib.focusedScreen
  }
  Polkit {
    theme: root.theme
  }
  Lock {
    theme: root.theme
  }
  Wallpaper {
    theme: root.theme
  }
}
