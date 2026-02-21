// ClockWidget.qml
import QtQuick

Item {
  id: root

  property int heightBox: 34
  property int widthMargin: 10
  property int heightMargin: 7

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"
  property int radius: 5

  signal toggleCalendar()

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Rectangle {
    id: box
    anchors {
      left: parent.left; top: parent.top
    }
    implicitWidth: text.implicitWidth + 2*widthMargin
    implicitHeight: root.heightBox
    radius: root.radius
    color: root.bg

    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin; topMargin: root.heightMargin
      }
      font.pixelSize: 14
      font.family: "Departure Mono"
      color: root.fg
      text: Time.timeLong
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.toggleCalendar()
    }
  }
}
