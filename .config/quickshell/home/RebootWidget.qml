// RebootWidget.qml
import QtQuick
import Quickshell.Io

Item {
  id: root

  property int heightBox: 34
  property int widthMargin: 7
  property int heightMargin: 7

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Process {
    id: rebootProc
    command: ["reboot"]
    //command: ["firefox"]
    running: false
  }

  Rectangle {
    id: box
    anchors {
      left: parent.left; top: parent.top
    }
    implicitWidth: text.implicitWidth + 2*widthMargin -2
    implicitHeight: root.heightBox
    radius: 5
    color: root.bg

    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin+3; topMargin: root.heightMargin
      }
      font.pixelSize: 14
      font.family: "Departure Mono"
      color: root.fg
      text: " "
    }
    
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: rebootProc.running = true
    }
  }
}
