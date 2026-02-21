// NotificationPopup.qml

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property int radius: 5

  visible: Notifications.visibleValues && Notifications.visibleValues.length > 0
  color: "transparent"
  implicitWidth: 300
  implicitHeight: Math.max(1, notiflist.implicitHeight) // safety net against crashes by wayland protocol
  anchor.rect.x: parentWindow.width - implicitWidth
  anchor.rect.y: parentWindow.height

  property int contentHeight: notiflist.contentHeight
  onContentHeightChanged: {
    root.implicitHeight = Math.max(1, notiflist.contentHeight) // update height dynamically + safety net
  }

  // Play notification sound when new notification arrives
  property int notificationCount: Notifications.visibleValues ? Notifications.visibleValues.length : 0
  property int previousCount: 0
  property int maxPopups: 3

  onNotificationCountChanged: {
    // Only play sound when a NEW notification arrives (count increases)
    if (notificationCount > previousCount && notificationCount > 0) {
      // Restart the sound process
      soundPlayer.running = false
      soundResetTimer.restart()

      // Limit to 3 popup notifications - instantly dismiss oldest when new one arrives
      if (notificationCount > maxPopups) {
        // Dismiss all except the 3 newest
        while (Notifications.visibleValues && Notifications.visibleValues.length > maxPopups) {
          var oldest = Notifications.visibleValues[0]
          if (oldest) {
            oldest.dismiss()
          } else {
            break
          }
        }
      }
    }
    previousCount = notificationCount
  }

  // Timer to restart sound process (ensures it's stopped before restarting)
  Timer {
    id: soundResetTimer
    interval: 50
    onTriggered: {
      soundPlayer.running = true
    }
  }

  Process {
    id: soundPlayer
    command: ["pw-play", "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"]
    running: false
  }

  ListView {
    id: notiflist
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }
    implicitHeight: contentHeight
    model: Notifications.visibleValues
    spacing: 6

    delegate: NotificationCard {
      n: modelData
      popup: true
      bg: root.fg
      fg: root.bg  
    }
  }
}
