import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Controls


Item {
  id: root
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property int radius: 5

  implicitHeight: calText.implicitHeight-27
  implicitWidth: parent.implicitWidth/2

  // Month offset from today (0 = this month)
  property int monthOffset: 0
  property string calOutput: ""

  Rectangle {
    id: card
    anchors.fill: parent
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.color1

    HoverHandler { id: hover }
    ToolTip.visible: hover.hovered
    ToolTip.text: "left click to go forward\nright click to go backwards"
    ToolTip.delay: 1000

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      onClicked: {
        root.monthOffset+=1
        proc.running = true
        //console.log(proc.command)
      }
    }
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.RightButton
      onClicked: {
        root.monthOffset-=1
        proc.running = true
        //console.log(proc.command)
      }
    }

    Text {
      id: calText
      anchors.fill: parent
      padding: 8
      font.pixelSize: 14
      font.family: "Departure Mono"
      color: root.fg
      textFormat: Text.PlainText
      text: root.calOutput.length > 0 ? root.calOutput : "loading…"
    }
  }

  // === Process in the requested form; all logic kept here/handlers ===
  Process {
    id: proc
    command: ["sh", "-c", "off="+root.monthOffset+"; d=$(date -d \"$(date +%Y-%m-01) ${off} month\" +\"%-m %Y\"); "+"set -- $d; cal -m $1 $2"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: { root.calOutput = this.text }
    }
  }
}