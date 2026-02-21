// Uptime.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string text: "0h 0m"

  Timer {
    running: true
    interval: 30000
    repeat: true
    triggeredOnStart: true
    onTriggered: uptimeProc.running = true
  }

  Process {
    id: uptimeProc
    command: ["cat", "/proc/uptime"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var secs = parseFloat(data.split(" ")[0])
        if (isNaN(secs)) return
        var hours = Math.floor(secs / 3600)
        var mins = Math.floor((secs % 3600) / 60)
        root.text = hours + "h " + mins + "m"
      }
    }
  }
}
