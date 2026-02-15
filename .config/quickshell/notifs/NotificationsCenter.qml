// NotificationCenter.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

PopupWindow {
  id: root
  
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property int radius: 5
  property int widthMargin: 5
  property int heightMargin: 5

  property bool open: false
  visible: open
  color: "transparent"
  implicitWidth: 420
  implicitHeight: 800

  anchor.rect.x: parentWindow.width - implicitWidth
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    Column {
      anchors.fill: parent
      spacing: 6
      padding: 6

      Rectangle {
        id: header
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.bg
        z: 1000
        Row {
          spacing: 6
          Text {
            id: headerText
            padding: 4
            font.pixelSize: 20
      font.family: "Departure Mono"
            text: "Notifications: "
            color: root.fg
          }
          Rectangle {
            implicitWidth: header.implicitWidth-button.implicitWidth-headerText.implicitWidth-6*2
            implicitHeight: 30
            color: "transparent"
          }
          Rectangle {
            id: button
            implicitWidth: buttonText.implicitWidth + 2*widthMargin
            implicitHeight: buttonText.implicitHeight + 2*heightMargin
            radius: 5
            color: root.fg

            Text {
              id: buttonText
              anchors {
                left: parent.left; top: parent.top
                leftMargin: root.widthMargin; topMargin: root.heightMargin
              }
              font.pixelSize: 14
      font.family: "Departure Mono"
              color: root.bg
              text: "Dismiss all"
            }
            
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifications.clearAll()
            }
          }
        }
      }
      ListView {
        id: list
        height: parent.height - header.height-12
        width: parent.width-12
        model: Notifications.model
        spacing: 6

        delegate: NotificationCard {
          n: modelData
          popup: false
          bg: root.bg
          fg: root.fg
          color1: root.color1
        }
      }
    }
  }
}