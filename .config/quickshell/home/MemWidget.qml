// MemWidget.qml
import QtQuick
import QtQuick.Controls

Item {
  id: root

  property int heightBox: 34
  property int widthMargin: 10
  property int heightMargin: 7

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"
  property color color1: "#FF00FF"

  //implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Rectangle {
    id: box
    anchors {
      left: parent.left; top: parent.top
    }
    implicitWidth: root.implicitWidth //text.implicitWidth + 2*widthMargin
    implicitHeight: root.heightBox
    radius : 5
    color: root.bg
    border.width: 2; border.color: root.color1

    HoverHandler { id: hover }
    ToolTip.visible: hover.hovered
    ToolTip.text: "memory usage"
    ToolTip.delay: 1000

    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin; topMargin: root.heightMargin
      }
      font.pixelSize: 14
      color: root.fg
      text: " "+Math.round(SystemUsage.memPerc*1000)/10+"%"
    }
  }
}
