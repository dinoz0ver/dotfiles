// WeatherWidget.qml
import QtQuick
import QtQuick.Controls // for tooltip

Item {
  id: root

  property int fontSize: 14
  property int heightBox: 34
  property int widthMargin: 10
  property int heightMargin: 7

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Rectangle {
    id: box
    anchors {
      left: parent.left; top: parent.top
    }
    implicitWidth: text.implicitWidth + 2*widthMargin
    implicitHeight: root.heightBox
    radius : 5
    color: root.bg
    
    HoverHandler { id: hover }
    ToolTip.visible: hover.hovered && Weather.tooltip.length > 0
    ToolTip.text: Weather.tooltip
    ToolTip.delay: 1000

    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin; topMargin: root.heightMargin
      }
      font.pixelSize: root.fontSize
      color: root.fg
      text: Weather.text
    }
  }
}
