// Bar.qml
import Quickshell
import "home" as Home
import "notifs" as Notifs

Scope {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData
      anchors {
        top: true
        left: true
        right: true
      }
      color: "transparent"
      implicitHeight: 46

      WalPalette { id: wal }

      Home.ControlWidget {
        id: controlWidget
        anchors {
          left: parent.left; top: parent.top
          leftMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
        onToggleCenter: controlCenter.open = !controlCenter.open
      }
      Home.ControlCenter {
        id: controlCenter
        anchor.window: bar
        bg: wal.bg
        fg: wal.fg
        color1: wal.color1
        color2: wal.color2
      }
      ClockWidget {
        id: clock
        anchors {
          left: controlWidget.right; top: parent.top
          leftMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
      }

      WorkspacesWidget {
        id: workspaces
        anchors {
          left: clock.right; top: parent.top
          leftMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
        color1: wal.color2
      }
      WindowTitleWidget {
        anchors {
          centerIn: parent 
        }
        bg: wal.bg
        fg: wal.fg
      }
      LanguageWidget {
        id: language
        anchors {
          right: battery.left; top: parent.top
          rightMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
      }
      WeatherWidget {
        id: weather
        anchors {
          left: workspaces.right; top: parent.top
          leftMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
      }
      BatteryWidget {
        id: battery
        anchors {
          right: notifWidget.left; top: parent.top
          rightMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
      }
      Notifs.NotificationsWidget {
        id: notifWidget
        anchors {
          right: parent.right; top: parent.top
          rightMargin: 6; topMargin: 6
        }
        bg: wal.bg
        fg: wal.fg
        onToggleCenter: notifCenter.open = !notifCenter.open
      }
      Notifs.NotificationsCenter {
        id: notifCenter
        anchor.window: bar
        bg: wal.bg
        fg: wal.fg
        color1: wal.color1
      }
      Notifs.NotificationsPopup {
        anchor.window: bar
        bg: wal.bg
        fg: wal.fg
      }
    }
  }
}
