// ControlCenter.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../notifs" as Notifs

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property int radius: 8

  property bool open: false
  visible: open

  color: "transparent"
  implicitWidth: 440
  implicitHeight: box.implicitHeight

  anchor.rect.x: 0
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6

  Process {
    id: settingsProc
    command: ["settings-center"]
    running: false
  }

  Rectangle {
    id: box
    width: parent.width
    implicitHeight: column.implicitHeight
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    y: root.open ? 0 : -20
    Behavior on y {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    opacity: root.open ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Column {
      id: column
      spacing: 10
      padding: 12
      width: parent.width

      // === HEADER ===
      Item {
        width: parent.width - 24
        height: 44

        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 10

          // Avatar circle
          ClippingRectangle {
            width: 40; height: 40
            radius: 20
            color: root.color1

            Image {
              id: avatarImg
              anchors.fill: parent
              source: "file:///home/dinozover/.config/quickshell/home/profile-icon"
              fillMode: Image.PreserveAspectCrop
              mipmap: true
              visible: status === Image.Ready
            }

            Text {
              anchors.centerIn: parent
              text: ""
              font.pixelSize: 20
              font.family: "Departure Mono"
              color: root.fg
              visible: avatarImg.status !== Image.Ready
            }
          }

          // Username + uptime
          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
              text: "Dinozover"
              font.pixelSize: 16
              font.family: "Departure Mono"
              font.bold: true
              color: root.fg
            }
            Text {
              text: "uptime " + Uptime.text
              font.pixelSize: 11
              font.family: "Departure Mono"
              color: root.fg
              opacity: 0.7
            }
          }
        }

        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // DND toggle
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: Notifs.Notifications.dnd ? root.color2 : root.color1

            Text {
              anchors.centerIn: parent
              text: Notifs.Notifications.dnd ? "󰂛" : "󰂚"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifs.Notifications.dnd = !Notifs.Notifications.dnd
            }
          }

          // Settings button
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: root.color1

            Text {
              anchors.centerIn: parent
              text: "\uf013"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: settingsProc.running = true
            }
          }

          // Power button
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: root.color1

            Text {
              anchors.centerIn: parent
              text: "\uf011"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: powerPopup.open = !powerPopup.open
            }
          }
        }
      }

      // Separator
      Rectangle {
        width: root.implicitWidth - 24
        height: 1
        color: root.color1
        opacity: 0.3
      }

      // === WIFI + BT CARDS + AUDIO SLIDERS ===
      Row {
        width: parent.width - 24
        spacing: 8

        // Left: wifi and bluetooth stacked
        Column {
          width: parent.width - slidersRow.width - 8
          spacing: 8

          NetworkWidget {
            id: network
            width: parent.width
            bg: root.bg; fg: root.fg
            color1: root.color1; color2: root.color2
            onToggleCenter: { networkPopup.open = !networkPopup.open; bluetoothPopup.open = false }
          }

          BluetoothWidget {
            id: bluetooth
            width: parent.width
            bg: root.bg; fg: root.fg
            color1: root.color1; color2: root.color2
            onToggleCenter: { bluetoothPopup.open = !bluetoothPopup.open; networkPopup.open = false }
          }
        }

        // Right: two vertical sliders side by side
        Row {
          id: slidersRow
          spacing: 6
          height: parent.height

          // Output volume slider
          Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Slider {
              id: outputSlider
              orientation: Qt.Vertical
              from: 0; to: 100
              implicitHeight: 108
              implicitWidth: 28
              value: Math.round((Audio.sink?.audio?.volume ?? 0) * 100)
              onMoved: Audio.setVolume(value, true)

              background: Rectangle {
                x: outputSlider.leftPadding + outputSlider.availableWidth / 2 - width / 2
                y: outputSlider.topPadding
                implicitWidth: 8
                implicitHeight: outputSlider.availableHeight
                width: implicitWidth
                height: outputSlider.availableHeight
                radius: 4
                color: root.color1

                Rectangle {
                  width: parent.width
                  height: (1.0 - outputSlider.visualPosition) * parent.height
                  y: outputSlider.visualPosition * parent.height
                  color: root.color2
                  radius: 4
                }
              }

              handle: Rectangle {
                x: outputSlider.leftPadding + outputSlider.availableWidth / 2 - width / 2
                y: outputSlider.topPadding + outputSlider.visualPosition * (outputSlider.availableHeight - height)
                implicitWidth: 18
                implicitHeight: 18
                radius: 9
                color: root.fg
              }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (Audio.sink?.audio?.muted ?? false) ? "󰖁" : "󰕾"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute(true)
              }
            }
          }

          // Mic volume slider
          Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Slider {
              id: micSlider
              orientation: Qt.Vertical
              from: 0; to: 100
              implicitHeight: 108
              implicitWidth: 28
              value: Math.round((Audio.source?.audio?.volume ?? 0) * 100)
              onMoved: Audio.setVolume(value, false)

              background: Rectangle {
                x: micSlider.leftPadding + micSlider.availableWidth / 2 - width / 2
                y: micSlider.topPadding
                implicitWidth: 8
                implicitHeight: micSlider.availableHeight
                width: implicitWidth
                height: micSlider.availableHeight
                radius: 4
                color: root.color1

                Rectangle {
                  width: parent.width
                  height: (1.0 - micSlider.visualPosition) * parent.height
                  y: micSlider.visualPosition * parent.height
                  color: root.color2
                  radius: 4
                }
              }

              handle: Rectangle {
                x: micSlider.leftPadding + micSlider.availableWidth / 2 - width / 2
                y: micSlider.topPadding + micSlider.visualPosition * (micSlider.availableHeight - height)
                implicitWidth: 18
                implicitHeight: 18
                radius: 9
                color: root.fg
              }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (Audio.source?.audio?.muted ?? false) ? "󰍭" : "󰍬"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute(false)
              }
            }
          }
        }
      }

      // Separator
      Rectangle {
        width: root.implicitWidth - 24
        height: 1
        color: root.color1
        opacity: 0.3
      }

      // === MEDIA PLAYER ===
      PlayerWidget {
        id: player
        implicitWidth: parent.width - 24
        bg: root.bg; fg: root.fg
        color1: root.color1; color2: root.color2
      }
    }
  }

  // === SUB-POPUPS ===
  BluetoothPopup {
    id: bluetoothPopup
    anchor.window: root
    bg: root.bg; fg: root.fg; color1: root.color1
    anchor.rect.x: 0
    anchor.rect.y: 6 + root.height
  }

  NetworkPopup {
    id: networkPopup
    anchor.window: root
    bg: root.bg; fg: root.fg; color1: root.color1
    anchor.rect.x: 0
    anchor.rect.y: 6 + root.height
  }

  PowerPopup {
    id: powerPopup
    anchor.window: root
    bg: root.bg; fg: root.fg
    color1: root.color1; color2: root.color2
    anchor.rect.x: root.implicitWidth - 180
    anchor.rect.y: 6 + root.height
  }
}
