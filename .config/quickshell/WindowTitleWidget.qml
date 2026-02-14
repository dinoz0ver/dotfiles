// WindowTitleWidget.qml
import QtQuick
import Quickshell.Hyprland
import QtQuick.Controls 

// to do: fix the bug: after closing every window in a workspace it will still show the last name of the window

Item {
  id: root

  property int heightBox: 34
  property int widthMargin: 10
  property int heightMargin: 7

  property color bg: "#FFFFFF"
  property color fg: "#0000FF"

  property string window: (Hyprland.activeToplevel && Hyprland.activeToplevel.title.length > 0 &&  Hyprland.activeToplevel.workspace.focused) ? Hyprland.activeToplevel.title : "amogus hehe"

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      Hyprland.refreshToplevels()
    }
  }

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
    ToolTip.visible: hover.hovered
    ToolTip.text: root.window
    ToolTip.delay: 1000

    Text {
      id: text
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin; topMargin: root.heightMargin
      }
      font.pixelSize: 14
      color: root.fg
      text: {if (root.window.length>60) return root.window.slice(0,60)+"..."
      else return root.window
      }
    }
  }
}
