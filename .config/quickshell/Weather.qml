// Weather.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/get_weather.sh"  // point to your script
  property string location: "Moscow"
  property int intervalMinutes: 10

  property string text: "..."
  property string tooltip: "..."
  property bool loaded: false

  Process {
    id: proc
    command: ["bash", root.scriptPath, location]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const obj = JSON.parse(this.text.trim())
          if (obj.text && obj.tooltip) {
            root.text = obj.text
            root.tooltip = obj.tooltip
            root.loaded = true
          } else {
            root.loaded = false
          }
        } catch (e) {
          root.loaded = false
        }
      }
    }
  }

  Timer {
    interval: root.intervalMinutes * 60 * 1000
    running: true
    repeat: true
    onTriggered: proc.running = true 
  }
}
