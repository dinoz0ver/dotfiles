// NetworkWidget.qml
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

  readonly property bool isConnected: Net.ethernetConnected || (Net.hasAdapter && Net.online)

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.isConnected ? root.color2 : root.bg
    border.width: 2
    border.color: root.isConnected ? root.color2 : root.color1

    Column {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: 12
      spacing: 2

      Row {
        spacing: 6
        Text {
          text: Net.ethernetConnected ? "󰈀" : ""
          font.pixelSize: 16
          font.family: "Departure Mono"
          color: root.fg
        }
        Text {
          text: "Internet"
          font.pixelSize: 14
          font.family: "Departure Mono"
          font.bold: true
          color: root.fg
        }
      }

      Text {
        text: {
          if (Net.ethernetConnected) return "Wired connection"
          if (Net.hasAdapter && Net.online && Net.activeSsid !== "") return Net.activeSsid
          return "Disconnected"
        }
        font.pixelSize: 12
        font.family: "Departure Mono"
        color: root.fg
        opacity: 0.7
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Net.ethernetConnected ? undefined : Qt.PointingHandCursor
      onClicked: {
        if (!Net.ethernetConnected) root.toggleCenter()
      }
    }
  }
}
