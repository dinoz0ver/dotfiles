// NotificationPopup.qml

import QtQuick
import Quickshell
import Quickshell.Widgets

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
