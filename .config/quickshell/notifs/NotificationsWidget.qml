// NotificationsWidget.qml
import QtQuick

Item {
  id: root
  property int heightBox: 34
  property int textMargin: 8
  property int radius: 5
  property color bg: "#00000000"
  property color fg: "#ffffff"
  signal toggleCenter()   // let Bar hook this

  implicitHeight: box.implicitHeight
  implicitWidth: box.implicitWidth

  Rectangle {
    id: box
    implicitWidth: text.implicitWidth + 2*root.textMargin
    implicitHeight: root.heightBox
    radius: root.radius
    color: root.bg
    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.textMargin; topMargin: root.textMargin
      }
      text: Notifications.count+" "
      font.pixelSize: 14
      color: root.fg
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
