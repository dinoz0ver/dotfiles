// BluetoothWidget.qml
import QtQuick

Item {
  id: root
  property int radius: 8
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  signal toggleCenter()

  implicitHeight: 60

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: (Bt.hasAdapter && Bt.adapter.enabled) ? root.color2 : root.bg
    border.width: 2
    border.color: (Bt.hasAdapter && Bt.adapter.enabled) ? root.color2 : root.color1

    Column {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: 12
      spacing: 2

      Row {
        spacing: 6
        Text {
          text: "󰂯"
          font.pixelSize: 16
          font.family: "Departure Mono"
          color: root.fg
        }
        Text {
          text: "Bluetooth"
          font.pixelSize: 14
          font.family: "Departure Mono"
          font.bold: true
          color: root.fg
        }
      }

      Text {
        text: {
          if (!Bt.hasAdapter) return "No adapter"
          if (!Bt.adapter.enabled) return "Disabled"
          if (Bt.connectedCount === 0) return "Not connected"
          if (Bt.connectedCount === 1) return Bt.adapter.devices.values[0].name
          return Bt.connectedCount + " connected"
        }
        font.pixelSize: 12
        font.family: "Departure Mono"
        color: root.fg
        opacity: 0.7
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: root.toggleCenter()
    }
  }
}
