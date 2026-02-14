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
  property bool open: false
  property int radius: 5

  implicitWidth: 440
  implicitHeight: 220
  color: "transparent"
  visible: open

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.color1
    border.width: 2; border.color: root.fg

    Column {
      anchors.fill: parent
      spacing: 6
      padding: 6
      Rectangle {
        id: header
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.color1
        z: 1000
        Row {
          spacing: 6
          Text {
            id: headerText
            padding: 4
            font.pixelSize: 16
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
            Text { 
              id: onOffText
              padding: 6
              text: Bt.adapter.enabled ? "Off" : "On"
              color: root.bg 
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Bt.adapter.enabled = !Bt.adapter.enabled
            }
          }
          Rectangle {
            implicitWidth: scanText.implicitWidth
            implicitHeight: 26
            color: enabled ? root.fg : root.color1
            enabled: Bt.adapter.enabled
            radius: 4
            border.width: 2; border.color: root.fg
            Text { 
              id: scanText
              padding: 6
              text: Bt.adapter.discovering ? "Stop scan" : "Scan"
              color: parent.enabled ? root.color1 : root.fg 
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Bt.adapter.discovering = !Bt.adapter.discovering
            }
          }
        }
      }

      ListView {
        id: list
        width: parent.width - 12
        height: parent.height - 90
        model: Bt.adapter.devices.values
        spacing: 6

        delegate: Rectangle {
          width: list.width
          height: 40
          color: root.fg
          radius: root.radius

          Row {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6
            Text {
              id: deviceNameText
              text: (modelData.name || "(unknown)")
              width: 200
              height: 26
              padding: 6
              color: root.bg
            }
            Rectangle {
              implicitWidth: (modelData.bonded ? root.implicitWidth-deviceNameText.width-connectText.implicitWidth-forgetText.implicitWidth-6*3-23 : root.implicitWidth-deviceNameText.width-connectText.implicitWidth-6*2-23)
              implicitHeight: 26
              color: "transparent"
            }
            // simple action button: Pair → Connect → Disconnect
            Rectangle {
              implicitWidth: connectText.implicitWidth
              implicitHeight: 26
              color: root.color1
              readonly property bool busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
              enabled: Bt.adapter.enabled && !busy
              radius: 4
              Text {
                id: connectText
                padding: 6
                text: parent.busy ? "Working…" : (modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair"))
                color: root.fg
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
              implicitWidth: forgetText.implicitWidth
              implicitHeight: 26
              color: root.color1
              enabled: Bt.adapter.enabled
              visible: modelData.bonded
              radius: 4
              Text { 
                id: forgetText
                padding: 6
                text:"Forget"
                color: root.fg
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
          text: Bt.adapter.discovering ? "Scanning…" :
             (list.count === 0 ? "No devices" : "")
          visible: text !== ""
        }
      }
    }
  }
}

