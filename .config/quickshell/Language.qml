pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io


Singleton {
  id: root
  property string language
  property string languageCode: ( language === "English (US)" ? "ENG" : ( language === "Russian" ? "RUS" : ""))

  Process {
    id: proc
    command: ["sh", "-c", "hyprctl -j devices | tr -d '\\n' | sed -E \"s/.*\\\"active_keymap\\\"[[:space:]]*:[[:space:]]*\\\"([^\\\"]+)\\\".*/\\1/\""]
    running: true
    stdout: StdioCollector {
      onStreamFinished: { root.language = this.text }
    }
  }

  Timer {
    interval: 500 // maybe make it faster but more cpu usage
    running: true
    repeat: true
    onTriggered: proc.running = true
  }
}

