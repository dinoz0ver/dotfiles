// PlayerWidget.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris
import QtQuick.Effects

Item {
  id: root

  property int radius: 8
  property color bg: "#ff0000"
  property color fg: "#00ff00"
  property color color1: "#ffff00"
  property color color2: "#ffff00"

  property int buttonWidth: 30
  property int buttonHeight: 30

  implicitHeight: 130
  implicitWidth: parent.implicitWidth

  readonly property MprisPlayer player: Player.player

  function formatTime(secs) {
    if (!secs || secs < 0) return "0:00"
    var totalSec = Math.floor(secs)
    var hrs = Math.floor(totalSec / 3600)
    var min = Math.floor((totalSec % 3600) / 60)
    var sec = totalSec % 60
    if (hrs > 0)
      return hrs + ":" + (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
    return min + ":" + (sec < 10 ? "0" : "") + sec
  }

  property real displayPosition: root.player ? root.player.position : 0
  property bool seeking: false
  property real seekPosition: 0
  property real shownPosition: seeking ? seekPosition : displayPosition

  property real trackLength: {
    if (!root.player) return 0
    var l = root.player.length
    console.log("[Player] length=" + l + " type=" + typeof l)
    if (l && l >= 1) return l
    // fallback: raw metadata mpris:length is in microseconds
    var meta = root.player.metadata
    var raw = meta ? meta["mpris:length"] : 0
    console.log("[Player] meta:length=" + raw + " type=" + typeof raw)
    if (raw && raw >= 1000000) return raw / 1000000
    return 0
  }

  // position doesn't update reactively — manually emit positionChanged()
  Timer {
    running: root.player !== null && root.player.isPlaying
    interval: 1000
    repeat: true
    onTriggered: {
      if (root.player) root.player.positionChanged()
    }
  }

  Connections {
    target: root.player
    enabled: root.player !== null
    function onPositionChanged() { root.displayPosition = root.player.position }
  }

  Rectangle {
    anchors.fill: parent
    color: root.bg
    radius: root.radius
    border.width: 2; border.color: root.color1
    clip: true

    Row {
      anchors.fill: parent
      spacing: 0

      // Album art square
      Item {
        width: root.height
        height: root.height

        Rectangle {
          id: artMask
          anchors.fill: parent
          anchors.margins: 6
          radius: root.radius
          color: "white"
          visible: false
          layer.enabled: true
        }

        // Background when no art
        Rectangle {
          anchors.fill: parent
          anchors.margins: 6
          radius: root.radius
          color: root.color1
          visible: !root.player || !root.player.trackArtUrl

          Text {
            anchors.centerIn: parent
            text: "\u266a"
            font.pixelSize: 32
            font.family: "Departure Mono"
            color: root.fg
          }
        }

        Image {
          id: albumArt
          anchors.fill: parent
          anchors.margins: 6
          source: root.player ? root.player.trackArtUrl : ""
          fillMode: Image.PreserveAspectCrop
          asynchronous: true; cache: true; smooth: true
          visible: false
        }

        MultiEffect {
          anchors.fill: albumArt
          source: albumArt
          maskEnabled: true
          maskSource: artMask
          visible: root.player && root.player.trackArtUrl
        }
      }

      // Right side: title, artist, progress, controls
      Column {
        width: parent.width - root.height
        height: parent.height
        spacing: 4
        padding: 8

        // Title
        Text {
          width: parent.width - 16
          text: root.player ? (root.player.trackTitle || "Unknown Title") : "No player"
          color: root.fg
          font.bold: true
          font.pixelSize: 13
          font.family: "Departure Mono"
          elide: Text.ElideRight
        }

        // Artist
        Text {
          width: parent.width - 16
          text: root.player ? (root.player.trackArtist || "Unknown Artist") : ""
          color: root.fg
          font.pixelSize: 12
          font.family: "Departure Mono"
          opacity: 0.8
          elide: Text.ElideRight
        }

        // Progress bar row
        Row {
          spacing: 4
          width: parent.width - 16

          // use wider labels when track is over an hour
          property bool isLong: (root.player ? root.trackLength : 0) >= 3600
          property int timeWidth: isLong ? 52 : 30

          Text {
            id: posText
            text: root.formatTime(root.shownPosition)
            font.pixelSize: 10
            font.family: "Departure Mono"
            color: root.fg
            width: parent.timeWidth
            anchors.verticalCenter: parent.verticalCenter
          }

          // Seekable progress bar with draggable thumb
          Item {
            id: progressArea
            width: parent.width - parent.timeWidth * 2 - 8
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            property real progress: {
              var len = root.player ? root.trackLength : 0
              if (len <= 0) return 0
              return Math.min(1, Math.max(0, root.shownPosition / len))
            }

            // Track background
            Rectangle {
              id: progressTrack
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width
              height: 4
              radius: 2
              color: root.color1

              // Filled portion
              Rectangle {
                width: progressArea.progress * parent.width
                height: parent.height
                radius: 2
                color: root.color2
              }
            }

            // Thumb
            Rectangle {
              id: thumb
              width: 12
              height: 12
              radius: 6
              color: root.fg
              visible: root.player && root.trackLength > 0
              anchors.verticalCenter: parent.verticalCenter
              x: progressArea.progress * (progressArea.width - width)
            }

            MouseArea {
              anchors.fill: parent
              anchors.topMargin: -4
              anchors.bottomMargin: -4
              enabled: root.player ? root.player.canSeek : false
              cursorShape: enabled ? Qt.PointingHandCursor : undefined

              onPressed: function(mouse) {
                var len = root.trackLength
                if (len <= 0) return
                root.seeking = true
                root.seekPosition = Math.max(0, Math.min(len, (mouse.x / width) * len))
              }

              onPositionChanged: function(mouse) {
                if (!root.seeking) return
                var len = root.trackLength
                if (len <= 0) return
                root.seekPosition = Math.max(0, Math.min(len, (mouse.x / width) * len))
              }

              onReleased: {
                if (!root.seeking) return
                if (root.player && root.player.canSeek) {
                  if (root.player.positionSupported) {
                    root.player.position = root.seekPosition
                  } else {
                    root.player.seek(root.seekPosition - root.displayPosition)
                  }
                }
                root.seeking = false
              }
            }
          }

          Text {
            id: lenText
            text: {
              var t = root.trackLength >= 1 ? root.formatTime(root.trackLength) : "--:--"
              return t
            }
            font.pixelSize: 10
            font.family: "Departure Mono"
            color: root.fg
            width: parent.timeWidth
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        // Transport controls: prev / play / next
        Row {
          spacing: 6
          anchors.horizontalCenter: parent.horizontalCenter

          Rectangle {
            color: root.player ? (root.player.canGoPrevious ? root.color2 : root.bg) : root.bg
            implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
            border.width: 2
            border.color: root.player ? (root.player.canGoPrevious ? root.color2 : root.color1) : root.color1
            radius: root.radius

            Text {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: 2
              text: "\u23ee"
              font.pixelSize: 20
              font.family: "Noto Sans Symbols 2"
              color: root.fg
            }

            MouseArea {
              enabled: root.player ? root.player.canGoPrevious : false
              anchors.fill: parent
              cursorShape: enabled ? Qt.PointingHandCursor : undefined
              onClicked: root.player.previous()
            }
          }

          Rectangle {
            color: root.player ? (root.player.canTogglePlaying ? root.color2 : root.bg) : root.bg
            implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
            border.width: 2
            border.color: root.player ? (root.player.canTogglePlaying ? root.color2 : root.color1) : root.color1
            radius: root.radius

            Text {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: 2
              text: (root.player && root.player.isPlaying) ? "\u23f8" : "\u25b6"
              font.pixelSize: 20
              font.family: "Noto Sans Symbols 2"
              color: root.fg
            }

            MouseArea {
              enabled: root.player ? root.player.canTogglePlaying : false
              anchors.fill: parent
              cursorShape: enabled ? Qt.PointingHandCursor : undefined
              onClicked: root.player.togglePlaying()
            }
          }

          Rectangle {
            color: root.player ? (root.player.canGoNext ? root.color2 : root.bg) : root.bg
            implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
            border.width: 2
            border.color: root.player ? (root.player.canGoNext ? root.color2 : root.color1) : root.color1
            radius: root.radius

            Text {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: 2
              text: "\u23ed"
              font.pixelSize: 20
              font.family: "Noto Sans Symbols 2"
              color: root.fg
            }

            MouseArea {
              enabled: root.player ? root.player.canGoNext : false
              anchors.fill: parent
              cursorShape: enabled ? Qt.PointingHandCursor : undefined
              onClicked: root.player.next()
            }
          }
        }
      }
    }
  }
}
