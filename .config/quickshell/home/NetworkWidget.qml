// NetworkWidget.qml
import QtQuick

Item {
  id: root
  property int heightBox: 34
  property int radius: 5
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  signal toggleCenter()   // let Bar hook this

  implicitHeight: box.implicitHeight
  implicitWidth: parent.implicitWidth/2

  Rectangle {
    id: box
    implicitWidth: root.implicitWidth
    implicitHeight: root.heightBox
    radius: root.radius
    color: Net.online ? root.color2 : root.bg
    border.width: 2; border.color: Net.online ? root.color2 : root.color1
    Text {
      id: text
      padding: 8
      text: ""+(Net.activeSsid != "" ? " "+Net.activeSsid : " Wifi")
      font.pixelSize: 14
      font.family: "Departure Mono"
      color: Net.online ? root.fg : root.fg
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.toggleCenter()
     }
  }
}
