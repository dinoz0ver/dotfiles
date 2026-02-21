// CalendarPopup.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import ".." as Root

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property int radius: 5

  property bool open: false
  visible: open
  color: "transparent"
  implicitWidth: 220
  implicitHeight: box.implicitHeight

  // Calendar properties
  property int monthOffset: 0
  property string calOutput: ""
  property string monthYearText: ""

  Rectangle {
    id: box
    width: parent.width
    implicitHeight: column.implicitHeight
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    // Smooth slide-down animation
    y: root.open ? 0 : -20
    Behavior on y {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    // Smooth fade animation
    opacity: root.open ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation {
        duration: 150
        easing.type: Easing.OutCubic
      }
    }

    Column {
      id: column
      spacing: 8
      padding: 8
      width: parent.width

      // Month navigation header
      Row {
        width: parent.width - 16

        Rectangle {
          id: prevButton
          width: 20
          height: 20
          radius: 3
          color: root.fg

          Text {
            anchors.centerIn: parent
            text: "<"
            font.pixelSize: 12
            font.family: "Departure Mono"
            font.bold: true
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

        Text {
          width: parent.width - 40
          height: 20
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          font.pixelSize: 14
          font.family: "Departure Mono"
          font.bold: true
          color: root.fg
          text: root.monthYearText
        }

        Rectangle {
          id: nextButton
          width: 20
          height: 20
          radius: 3
          color: root.fg

          Text {
            anchors.centerIn: parent
            text: ">"
            font.pixelSize: 12
            font.family: "Departure Mono"
            font.bold: true
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

      // Calendar grid
      Text {
        id: calText
        width: parent.width - 16
        padding: 4
        font.pixelSize: 14
        font.family: "Departure Mono"
        color: root.fg
        textFormat: Text.RichText
        text: root.calOutput.length > 0 ? root.calOutput : "loading…"
      }
    }
  }

  // Calendar process
  Process {
    id: proc
    command: ["sh", "-c", "off=" + root.monthOffset + "; target=$(date -d \"$(date +%Y-%m-01) ${off} month\" +%Y-%m-01); date -d \"$target\" +\"%B %Y\"; date -d \"$target\" +%u; date -d \"$target +1 month -1 day\" +%d; date -d \"$target -1 day\" +%d; date +%Y-%m-%d; date -d \"$target\" +%Y-%m"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let lines = this.text.trim().split('\n')
        let monthYear = lines[0]
        let dow = parseInt(lines[1])
        let daysInMonth = parseInt(lines[2])
        let daysInPrev = parseInt(lines[3])
        let todayFull = lines[4]
        let targetYM = lines[5]

        let isCurrentMonth = (todayFull.substring(0, 7) === targetYM)
        let today = isCurrentMonth ? parseInt(todayFull.substring(8, 10)) : -1

        let cells = []

        // Previous month padding (dow: 1=Mon..7=Sun)
        let startPad = dow - 1
        for (let i = startPad; i > 0; i--)
          cells.push({ day: daysInPrev - i + 1, current: false })

        // Current month
        for (let d = 1; d <= daysInMonth; d++)
          cells.push({ day: d, current: true, isToday: d === today })

        // Next month padding to complete the grid
        let totalCells = Math.ceil(cells.length / 7) * 7
        if (totalCells < 35) totalCells = 35
        let nextDay = 1
        while (cells.length < totalCells)
          cells.push({ day: nextDay++, current: false })

        // Dim color for neighboring months
        let r = Math.round(root.fg.r * 255)
        let g = Math.round(root.fg.g * 255)
        let b = Math.round(root.fg.b * 255)
        let dimColor = 'rgba(' + r + ',' + g + ',' + b + ',0.3)'

        root.monthYearText = monthYear

        let html = '<table cellspacing="5" cellpadding="2" style="font-family: Departure Mono; font-size: 14px; color: ' + root.fg + ';">'

        let dayNames = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
        html += '<tr>'
        for (let d = 0; d < 7; d++)
          html += '<td align="center">' + dayNames[d] + '</td>'
        html += '</tr>'

        for (let i = 0; i < cells.length; i++) {
          if (i % 7 === 0) html += '<tr>'
          let c = cells[i]
          let style = ''
          if (c.isToday)
            style = ' style="background-color: ' + root.color1 + '; color: ' + root.bg + ';"'
          else if (!c.current)
            style = ' style="color: ' + dimColor + ';"'
          html += '<td align="right"' + style + '>' + c.day + '</td>'
          if ((i + 1) % 7 === 0) html += '</tr>'
        }

        html += '</table>'
        root.calOutput = html
      }
    }
  }
}
