// Time.qml
pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string timeLong: Qt.formatDateTime(clock.date, "ddd, d MMM yyyy | hh:mm")
  readonly property string timeShort: Qt.formatDateTime(clock.date, "hh:mm")

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
