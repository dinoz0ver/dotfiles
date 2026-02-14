// WalPalette.qml
import QtQuick
import Qt.labs.platform as Labs        // for StandardPaths (Home dir)
import Quickshell.Io                   // FileView + JsonAdapter

QtObject {
  id: wal

  // Path to pywal/pywal16 JSON (e.g. ~/.cache/wal/colors.json)
  property string walPath: Labs.StandardPaths.writableLocation(Labs.StandardPaths.HomeLocation) + "/.cache/wal/colors.json"

  // Holds the file reader/adapter as a property (QtObject can't have free children)
  property var file: FileView {
    path: wal.walPath
    watchChanges: true
    adapter: JsonAdapter {
      // If your JsonAdapter needs an explicit schema/object hookup, keep it here.
      // Many Quickshell configs just access adapter.special / adapter.colors directly.
      // These fallbacks avoid undefined access when the file isn't present yet.
      property var special: ({})
      property var colors:  ({})
    }
  }

  // Convenient getters with safe fallbacks
  readonly property color bg: (file.adapter && file.adapter.special && file.adapter.special.background) || "#000000"
  readonly property color fg: (file.adapter && file.adapter.special && file.adapter.special.foreground) || "#ffffff"

  // Normal & bright ANSI slots
  readonly property var c: (file.adapter && file.adapter.colors) || ({})
  // Handy picks
  readonly property color color1: (c.color1 || "#ffffff")
  readonly property color color2: (c.color2 || "#000000")
  readonly property color color3: (c.color3 || "#ff0000")
  readonly property color color4: (c.color4 || "#f0f000")
  readonly property color color5: (c.color5 || "#00ff00")
  readonly property color color6: (c.color6 || "#0000ff")
  readonly property color color7: (c.color7 || "#ffff00")
  readonly property color color8: (c.color8 || "#00ffff")
  readonly property color color9: (c.color9 || "#ff00ff")
  readonly property color color10: (c.color10 || "#f00000")
  readonly property color color11: (c.color11 || "#0f0000")
  readonly property color color12: (c.color12 || "#00f000")
  readonly property color color13: (c.color13 || "#000f00")
  readonly property color color14: (c.color14 || "#0000f0")
  readonly property color color15: (c.color15 || "#00000f")
  readonly property color color16: (c.color16 || "#f00f00")
}
