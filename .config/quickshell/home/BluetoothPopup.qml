// BluetoothWidget.qml
import QtQuick
import QtQuick.Controls
import Quickshell.Bluetooth
import Quickshell

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property bool open: false
  property int radius: 8

  implicitWidth: 440
  implicitHeight: 220
  color: "transparent"
  visible: open

  Rectangle {
    width: parent.width
    height: parent.height
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
      anchors.fill: parent
      spacing: 6
      padding: 6
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
            font.pixelSize: 16
      font.family: "Departure Mono"
            text: "Bluetooth"
            color: root.fg
          }
          Rectangle {
            implicitWidth: root.implicitWidth-onOffText.implicitWidth-scanText.implicitWidth-headerText.implicitWidth-6*3-12
            implicitHeight: 26
            color: "transparent"
          }
          Rectangle {
            implicitWidth: onOffText.implicitWidth
            implicitHeight: 26
            color: root.fg
            radius: 4
            visible: Bt.hasAdapter
            Text {
              id: onOffText
              padding: 6
              text: (Bt.hasAdapter && Bt.adapter.enabled) ? "Off" : "On"
              color: root.bg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Bt.hasAdapter) Bt.adapter.enabled = !Bt.adapter.enabled
            }
          }
          Rectangle {
            implicitWidth: scanText.implicitWidth
            implicitHeight: 26
            color: enabled ? root.fg : root.color1
            enabled: Bt.hasAdapter && Bt.adapter.enabled
            radius: 4
            border.width: 2; border.color: root.fg
            visible: Bt.hasAdapter
            Text {
              id: scanText
              padding: 6
              text: (Bt.hasAdapter && Bt.adapter.discovering) ? "Stop scan" : "Scan"
              color: parent.enabled ? root.color1 : root.fg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Bt.hasAdapter) Bt.adapter.discovering = !Bt.adapter.discovering
            }
          }
        }
      }

      ListView {
        id: list
        width: parent.width - 12
        height: parent.height - 90
        model: Bt.hasAdapter ? Bt.adapter.devices.values : []
        spacing: 6

        delegate: Rectangle {
          width: list.width
          height: 40
          color: root.bg
          radius: root.radius
          border.color: root.color1
          border.width: 2

          Row {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6
            Text {
              id: deviceNameText
              text: (modelData.name || "(unknown)")
              padding: 6
              color: root.fg
              font.family: "Departure Mono"
            }
            Rectangle {
              width: parent.width - deviceNameText.implicitWidth - connectButton.width - (modelData.bonded ? forgetButton.width + 6 : 0) - 6*2
              height: 26
              color: "transparent"
            }
            // simple action button: Pair → Connect → Disconnect
            Rectangle {
              id: connectButton
              width: Math.max(connectText.implicitWidth + 12, 80)
              height: 26
              color: root.color1
              readonly property bool busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
              enabled: Bt.hasAdapter && Bt.adapter.enabled && !busy
              radius: 4
              Text {
                id: connectText
                anchors.fill: parent
                text: parent.busy ? "Working…" : (modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair"))
                color: root.fg
                font.family: "Departure Mono"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (parent.busy) return
                  if (modelData.connected) modelData.disconnect()
                  else if (modelData.paired) modelData.connect()
                  else modelData.pair()
                }
              }
            }
            Rectangle {
              id: forgetButton
              width: Math.max(forgetText.implicitWidth + 12, 70)
              height: 26
              color: root.color1
              enabled: Bt.hasAdapter && Bt.adapter.enabled
              visible: modelData.bonded
              radius: 4
              Text {
                id: forgetText
                anchors.fill: parent
                text:"Forget"
                color: root.fg
                font.family: "Departure Mono"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.forget()
              }
            }
          }
        }

        ScrollBar.vertical: ScrollBar {}
        footer: Text {
          width: list.width; height: 28
          horizontalAlignment: Text.AlignHCenter
          color: root.fg
          font.family: "Departure Mono"
          text: !Bt.hasAdapter ? "No adapter" :
             ((Bt.hasAdapter && Bt.adapter.discovering) ? "Scanning…" :
             (list.count === 0 ? "No devices" : ""))
          visible: text !== ""
        }
      }
    }
  }
}

