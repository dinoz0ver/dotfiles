// Bar.qml
import QtQuick
import Quickshell
import Quickshell.Io
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
      Home.PopupOverlay {
        id: controlOverlay
        screen: modelData
        active: controlCenter.open
        onClicked: controlCenter.open = false
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
        onToggleCalendar: calendarPopup.open = !calendarPopup.open
      }
      Home.PopupOverlay {
        id: calendarOverlay
        screen: modelData
        active: calendarPopup.open
        onClicked: calendarPopup.open = false
      }
      Home.CalendarPopup {
        id: calendarPopup
        anchor.window: bar
        anchor.rect.x: clock.x
        anchor.rect.y: bar.height
        anchor.margins.top: 6
        bg: wal.bg
        fg: wal.fg
        color1: wal.color1
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
        currentScreen: modelData
      }
      WindowTitleWidget {
        id: windowTitle
        anchors {
          centerIn: parent
        }
        bg: wal.bg
        fg: wal.fg
        currentScreen: modelData
      }
      LanguageWidget {
        id: language
        anchors {
          right: battery.visible ? battery.left : notifWidget.left; top: parent.top
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
      Home.PopupOverlay {
        id: notifOverlay
        screen: modelData
        active: notifCenter.open
        onClicked: notifCenter.open = false
      }
      Notifs.NotificationsCenter {
        id: notifCenter
        anchor.window: bar
        bg: wal.bg
        fg: wal.fg
        color1: wal.color1
        color2: wal.color2
        color4: wal.color4
      }
      // Only show notification popups on the primary (first) screen
      // Use screen position as a reliable indicator
      property bool isPrimaryScreen: {
        // Primary screen is typically at (0,0) position
        return modelData.x === 0 && modelData.y === 0
      }

      // Separate popup for each notification (up to 3)
      // Each popup binds to its own slot - no shifting when others are dismissed
      Notifs.SingleNotificationPopup {
        id: notifPopup0
        anchor.window: bar
        bg: wal.fg
        fg: wal.bg
        color1: wal.color1
        color2: wal.color2
        color4: wal.color4
        popupIndex: 0
        verticalOffset: 0
        previousSlotOffset: 0
        notification: bar.isPrimaryScreen ? Notifs.Notifications.popupAt(0) : null
      }
      Notifs.SingleNotificationPopup {
        id: notifPopup1
        anchor.window: bar
        bg: wal.fg
        fg: wal.bg
        color1: wal.color1
        color2: wal.color2
        color4: wal.color4
        popupIndex: 1
        verticalOffset: (notifPopup0.visible && notifPopup0.notification && !notifPopup0.dismissing) ? (notifPopup0.implicitHeight + 6) : 0
        previousSlotOffset: 0  // shifted from popup0's position (offset 0)
        notification: bar.isPrimaryScreen ? Notifs.Notifications.popupAt(1) : null
      }
      Notifs.SingleNotificationPopup {
        id: notifPopup2
        anchor.window: bar
        bg: wal.fg
        fg: wal.bg
        color1: wal.color1
        color2: wal.color2
        color4: wal.color4
        popupIndex: 2
        verticalOffset: {
          let offset = 0
          if (notifPopup0.visible && notifPopup0.notification && !notifPopup0.dismissing) offset += notifPopup0.implicitHeight + 6
          if (notifPopup1.visible && notifPopup1.notification && !notifPopup1.dismissing) offset += notifPopup1.implicitHeight + 6
          return offset
        }
        previousSlotOffset: notifPopup1.verticalOffset  // shifted from popup1's position
        notification: bar.isPrimaryScreen ? Notifs.Notifications.popupAt(2) : null
      }
      // 4th popup: eviction animation for oldest notification pushed off the stack
      Notifs.SingleNotificationPopup {
        id: notifPopupEvict
        anchor.window: bar
        bg: wal.fg
        fg: wal.bg
        color1: wal.color1
        color2: wal.color2
        color4: wal.color4
        popupIndex: 3
        verticalOffset: {
          let offset = 0
          if (notifPopup0.notification && !notifPopup0.dismissing) offset += notifPopup0.implicitHeight + 6
          if (notifPopup1.notification && !notifPopup1.dismissing) offset += notifPopup1.implicitHeight + 6
          if (notifPopup2.notification && !notifPopup2.dismissing) offset += notifPopup2.implicitHeight + 6
          return offset
        }
        previousSlotOffset: notifPopup2.verticalOffset  // evicted from popup2's position
        notification: bar.isPrimaryScreen ? Notifs.Notifications.popupAt(3) : null
      }

      // Notification sound handler (only on primary screen)
      // Track total count to detect truly new notifications
      property int lastTotalCount: 0

      Connections {
        target: Notifs.Notifications
        function onPopupQueueChanged() {
          if (!bar.isPrimaryScreen) return

          const q = Notifs.Notifications.popupQueue
          const qIds = q.map(function(n) { return n ? n.id : "null" })
          console.log("[Notif] queue:", JSON.stringify(qIds), "total:", Notifs.Notifications.count)
        }
        function onCountChanged() {
          if (!bar.isPrimaryScreen) return
          bar.lastTotalCount = Notifs.Notifications.count
        }
      }
    }
  }
}
