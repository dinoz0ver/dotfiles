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

  implicitHeight: 200
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

    Row {
      anchors.fill: parent
      spacing: 4

      Text {
        id: calText
        width: parent.width - 30
        height: parent.height
        padding: 8
        font.pixelSize: 14
        font.family: "Departure Mono"
        color: root.fg
        textFormat: Text.RichText
        text: root.calOutput.length > 0 ? root.calOutput : "loading…"
      }

      // Navigation buttons
      Column {
        width: 22
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Rectangle {
          id: prevButton
          width: parent.width - 8
          height: width
          radius: 3
          color: root.fg

          Text {
            anchors.centerIn: parent
            text: "▲"
            font.pixelSize: 10
            font.family: "Departure Mono"
            color: root.bg
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.monthOffset -= 1
              proc.running = true
            }
          }
        }

        Rectangle {
          id: nextButton
          width: parent.width - 8
          height: width
          radius: 3
          color: root.fg

          Text {
            anchors.centerIn: parent
            text: "▼"
            font.pixelSize: 10
            font.family: "Departure Mono"
            color: root.bg
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.monthOffset += 1
              proc.running = true
            }
          }
        }
      }
    }
  }

  // === Process in the requested form; all logic kept here/handlers ===
  Process {
    id: proc
    command: ["sh", "-c", "off="+root.monthOffset+"; d=$(date -d \"$(date +%Y-%m-01) ${off} month\" +\"%-m %Y\"); "+"set -- $d; cal -m $1 $2"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let output = this.text

        // Highlight current day if viewing current month
        if (root.monthOffset === 0) {
          const today = new Date().getDate()
          const todayStr = String(today)

          // Escape HTML special chars first
          output = output.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

          // Find the day number - try different positions
          let searchPattern = ' ' + todayStr + ' '
          let index = output.indexOf(searchPattern)
          let spaceBefore = 1
          let spaceAfter = 1

          if (index === -1) {
            // Try with newline after (day at end of line)
            searchPattern = ' ' + todayStr + '\n'
            index = output.indexOf(searchPattern)
            spaceAfter = 1
          }

          if (index === -1) {
            // Try with newline before (day at start of line)
            searchPattern = '\n' + todayStr + ' '
            index = output.indexOf(searchPattern)
            spaceBefore = 1
            spaceAfter = 1
          }

          if (index !== -1) {
            const before = output.substring(0, index + spaceBefore) // keep the leading space/newline
            const after = output.substring(index + spaceBefore + todayStr.length)
            // Add zero-width space after span to prevent background bleeding at line breaks
            output = before + '<span style="background-color: ' + root.color1 + '; color: ' + root.bg + ';">' + todayStr + '</span>\u200B' + after
          }

          output = '<pre style="margin: 0; font-family: Departure Mono; color: ' + root.fg + ';">' + output + '</pre>'
        } else {
          output = '<pre style="margin: 0; font-family: Departure Mono; color: ' + root.fg + ';">' + output.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</pre>'
        }

        root.calOutput = output
      }
    }
  }
}