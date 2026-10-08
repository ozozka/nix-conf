pragma Singleton
import QtQuick
import Quickshell

Singleton {
  readonly property string time: Qt.formatTime(clock.date, "hh:mm:ss")
  readonly property string date: Qt.formatDate(clock.date, "yyyy-MM-dd")

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
