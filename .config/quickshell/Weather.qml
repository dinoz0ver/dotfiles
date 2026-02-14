// Weather.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string scriptPath: "/home/dinozover/.config/quickshell/scripts/get_weather.sh"  // point to your script
  property string location: "Moscow"
  property int intervalMinutes: 10

  property string text: "..."
  property string tooltip: "..."

  Process {
    id: proc
    command: ["bash", root.scriptPath, location]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const obj = JSON.parse(this.text.trim())
          root.text = obj.text || "error"
          root.tooltip = obj.tooltip || "error"
        } catch (e) {
          root.text = "error"
          root.tooltip = "error"
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
