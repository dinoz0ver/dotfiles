// PowerPopup.qml
import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property int radius: 8

  property bool open: false
  property string confirmAction: ""

  visible: open
  onOpenChanged: if (!open) confirmAction = ""
  color: "transparent"
  implicitWidth: 180
  implicitHeight: box.implicitHeight

  Process {
    id: shutdownProc
    command: ["shutdown", "now"]
    running: false
  }

  Process {
    id: rebootProc
    command: ["reboot"]
    running: false
  }

  Process {
    id: lockProc
    command: ["hyprlock"]
    running: false
  }

  Rectangle {
    id: box
    width: parent.width
    implicitHeight: col.implicitHeight
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    y: root.open ? 0 : -20
    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    opacity: root.open ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Column {
      id: col
      padding: 8
      spacing: 4
      width: parent.width

      // Shutdown row
      Rectangle {
        visible: root.confirmAction === ""
        width: parent.width - 16
        height: 32; radius: root.radius
        color: "transparent"

        Row {
          anchors.fill: parent
          anchors.leftMargin: 8
          spacing: 8

          Text {
            text: "\uf011"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Shutdown"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.confirmAction = "shutdown"
        }
      }

      // Reboot row
      Rectangle {
        visible: root.confirmAction === ""
        width: parent.width - 16
        height: 32; radius: root.radius
        color: "transparent"

        Row {
          anchors.fill: parent
          anchors.leftMargin: 8
          spacing: 8

          Text {
            text: "\uf01e"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Reboot"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.confirmAction = "reboot"
        }
      }

      // Lock row (no confirmation)
      Rectangle {
        visible: root.confirmAction === ""
        width: parent.width - 16
        height: 32; radius: root.radius
        color: "transparent"

        Row {
          anchors.fill: parent
          anchors.leftMargin: 8
          spacing: 8

          Text {
            text: "\uf023"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Lock"
            font.pixelSize: 14
            font.family: "Departure Mono"
            color: root.fg
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: { lockProc.running = true; root.open = false }
        }
      }

      // Confirmation state
      Column {
        visible: root.confirmAction !== ""
        spacing: 8
        width: parent.width - 16

        Text {
          text: "are u sure?"
          color: root.fg
          font.pixelSize: 13
          font.family: "Departure Mono"
          anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
          spacing: 8
          anchors.horizontalCenter: parent.horizontalCenter

          Rectangle {
            width: 46; height: 26
            radius: 4
            color: root.fg

            Text {
              anchors.centerIn: parent
              text: "yes"
              color: root.bg
              font.pixelSize: 12
              font.family: "Departure Mono"
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.confirmAction === "shutdown") shutdownProc.running = true
                else if (root.confirmAction === "reboot") rebootProc.running = true
                root.confirmAction = ""
                root.open = false
              }
            }
          }

          Rectangle {
            width: 46; height: 26
            radius: 4
            color: root.bg
            border.width: 1; border.color: root.fg

            Text {
              anchors.centerIn: parent
              text: "no"
              color: root.fg
              font.pixelSize: 12
              font.family: "Departure Mono"
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.confirmAction = ""
            }
          }
        }
      }
    }
  }
}
