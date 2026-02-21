// NotificationCenter.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#00ff00"
  property color color4: "#f0f000"
  property int radius: 5
  property int widthMargin: 5
  property int heightMargin: 5

  property bool open: false
  visible: open
  color: "transparent"
  implicitWidth: 420
  implicitHeight: Notifications.savedNotifications.length === 0
    ? header.implicitHeight + emptyText.implicitHeight + 40
    : Math.min(800, list.contentHeight + header.implicitHeight + 40)

  anchor.rect.x: parentWindow.width - implicitWidth
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6

  Rectangle {
    id: box
    width: parent.width
    height: parent.height
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    // Smooth slide-down animation
    y: root.open ? 0 : -20
    Behavior on y {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    // Smooth fade animation
    opacity: root.open ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }

    Column {
      anchors.fill: parent
      spacing: 8
      padding: 8

      Rectangle {
        id: header
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.bg
        z: 1000
        Row {
          spacing: 6
          Text {
            id: headerText
            padding: 4
            font.pixelSize: 20
      font.family: "Departure Mono"
            text: "Notifications: "
            color: root.fg
          }
          Rectangle {
            implicitWidth: header.implicitWidth-button.implicitWidth-headerText.implicitWidth-6*2
            implicitHeight: 30
            color: "transparent"
          }
          Rectangle {
            id: button
            implicitWidth: buttonText.implicitWidth + 2*widthMargin
            implicitHeight: buttonText.implicitHeight + 2*heightMargin
            radius: 5
            color: buttonMouse.containsMouse ? root.color1 : root.fg

            // Smooth color transition
            Behavior on color {
              ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
              }
            }

            Text {
              id: buttonText
              anchors {
                left: parent.left; top: parent.top
                leftMargin: root.widthMargin; topMargin: root.heightMargin
              }
              text: "Dismiss all"
              font.pixelSize: 14
              font.family: "Departure Mono"
              color: buttonMouse.containsMouse ? root.fg : root.bg

              // Smooth color transition
              Behavior on color {
                ColorAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
            }

            MouseArea {
              id: buttonMouse
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifications.clearAll()
            }
          }
        }
      }
      Text {
        id: emptyText
        visible: Notifications.savedNotifications.length === 0
        text: "No notifications"
        color: root.fg
        font.pixelSize: 14
        font.family: "Departure Mono"
        horizontalAlignment: Text.AlignHCenter
        width: parent.width - 12
        topPadding: 8
      }
      ListView {
        id: list
        visible: Notifications.savedNotifications.length > 0
        property bool atMax: list.contentHeight + header.implicitHeight + 40 > 800
        height: parent.height - header.height - 24
        width: parent.width-12
        model: Notifications.savedNotifications
        spacing: 6
        clip: atMax
        interactive: atMax

        ScrollBar.vertical: ScrollBar {
          policy: list.atMax ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        }

        delegate: NotificationCard {
          n: modelData
          popup: false
          bg: root.bg
          fg: root.fg
          color1: root.color1
          color2: root.color2
          color4: root.color4
        }
      }
    }
  }
}