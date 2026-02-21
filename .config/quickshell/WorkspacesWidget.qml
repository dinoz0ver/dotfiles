import Quickshell
import QtQuick
import Quickshell.Hyprland
// make the cursor like i can click on this

Item {
  id: root

  property int widthRow: 34
  property int heightRow: 34
  property int radiusRect: 5
  property int radiusRow: 4
  property int fontSize: 14

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"
  property color color1: "#FF0000"
  property var currentScreen

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Rectangle {
    id: box
    anchors {
      left: parent.left; top: parent.top
    }
    radius: root.radiusRect
    color: root.bg
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
      id: row
      anchors.centerIn: parent      

      Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
          visible: modelData && (!root.currentScreen || modelData.monitor?.name === root.currentScreen.name)
          implicitWidth: root.widthRow
          implicitHeight: root.heightRow
          radius: root.radiusRow
          property bool isFocused: Hyprland.focusedWorkspace && modelData.id === Hyprland.focusedWorkspace.id
          color: isFocused ? root.color1 : "transparent"
          Text {
            anchors.centerIn: parent
            text: String(modelData.id)      // number in each box
            font.pixelSize: root.fontSize
            font.family: "Departure Mono"
            color: isFocused ? root.fg : root.color1
          }
          MouseArea {
            anchors.fill: parent
            onClicked: modelData.activate()
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
          }
        }
      }
    }
  }
}
