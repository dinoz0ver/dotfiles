// BluetoothWidget.qml
import QtQuick

// to do: idk why, but bluetooth is always on after startup

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
    color: Bt.adapter.enabled ? root.color2 : root.bg
    border.width: 2; border.color: Bt.adapter.enabled ? root.color2 : root.color1
    Text {
      id: text
      padding: 8
      text: "󰂯"+( Bt.connectedCount == 0 ? " Bluetooth" : (Bt.connectedCount == 1 ? " "+Bt.adapter.devices.values[0].name : Bt.connectedCount+" devices connected"))
      font.pixelSize: 14
      color: Bt.adapter.enabled ? root.fg : root.fg
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
