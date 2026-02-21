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
    command: ["sh", "-c", "hyprctl -j devices | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | tr -d '\\n'"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: { root.language = this.text.trim() }
    }
  }

  Timer {
    interval: 500 // maybe make it faster but more cpu usage
    running: true
    repeat: true
    onTriggered: proc.running = true
  }
}

