// PlayerWidget.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Mpris

Item {
  id: root

  property int radius: 4
  property int fontSize: 14
  property color bg: "#ff0000"
  property color fg: "#00ff00"
  property color color1: "#ffff00"
  property color color2: "#ffff00"

  property int buttonWidth: 25
  property int buttonHeight: 25
  property int buttonTopMargin: 0
  property int buttonLeftMargin: 7
  property int buttonFontSize: 20

  implicitHeight: 34
  implicitWidth: parent.implicitWidth
  visible: true

  readonly property MprisPlayer player: Player.player;

  Rectangle {
    anchors.fill: parent
    color: root.bg
    radius: root.radius
    border.width: 2; border.color: root.color1

    Row {
      spacing: 8
      padding: 5
      Rectangle {
        id: artistTitleLabel
        property int pos: 30
        implicitWidth: label.implicitWidth+8; implicitHeight: root.buttonHeight
        color: "transparent"
        Text {
          id: label
          color: root.fg
          anchors.fill: parent
          padding: 2
          text: {
            if (!root.player) return "No player";
            const artist = root.player.trackArtist || "Unknown Artist";
            const title  = root.player.trackTitle  || "Unknown Title";
            return ("                                   "+artist+" - "+title+"                                   ").slice(parent.pos, parent.pos+35);
          }
          font.bold: true
          font.pixelSize: root.fontSize
        }
        Timer {
          interval: 250
          running: true
          repeat: true
          onTriggered: {
            parent.pos +=1
            if (parent.pos>label.text.length+70) {
              parent.pos = 0
            }
          }
        }      
      }
      Rectangle {
        implicitWidth: root.implicitWidth-artistTitleLabel.implicitWidth-previousButton.implicitWidth-playButton.implicitWidth-nextButton.implicitWidth-42
        implicitHeight: root.buttonHeight
        color: "transparent"
      }
      Rectangle {
        id: previousButton
        color: root.player ? (root.player.canGoPrevious ? root.color2 : root.bg) : root.bg
        implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
        border.width: 2; border.color: root.player ? (root.player.canGoPrevious ? root.color2 : root.color1) : root.color1
        Text { 
          anchors {
            left: parent.left; top: parent.top
            leftMargin: root.buttonLeftMargin; topMargin: root.buttonTopMargin
          }
          text: "⏮"
          font.pixelSize: root.buttonFontSize
          color: root.player ? (root.player.canGoPrevious ? root.fg : root.fg) : root.fg
        } 
        radius: root.radius
        MouseArea {
          enabled: root.player ? root.player.canGoPrevious : false
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton
          hoverEnabled: true
          cursorShape: enabled ? Qt.PointingHandCursor : undefined
          onClicked: { root.player.previous() }
        }
      }
      Rectangle {
        id: playButton
        color: root.player ? (root.player.canTogglePlaying ? root.color2 : root.bg) : root.bg
        implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
        border.width: 2; border.color: root.player ? (root.player.canTogglePlaying ? root.color2 : root.color1) : root.color1
        Text { 
          anchors {
            left: parent.left; top: parent.top
            leftMargin: root.buttonLeftMargin; topMargin: root.buttonTopMargin
          }
          text: (root.player && root.player.isPlaying) ? "⏸" : "▶"
          font.pixelSize: root.buttonFontSize
          color: root.player ? (root.player.canTogglePlaying ? root.fg : root.fg) : root.fg
        } 
        radius: root.radius
        MouseArea {
          enabled: root.player ? root.player.canTogglePlaying : false
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton
          hoverEnabled: true
          cursorShape: enabled ? Qt.PointingHandCursor : undefined
          onClicked: { root.player.togglePlaying() }
        }
      }
      Rectangle {
        id: nextButton
        color: root.player ? (root.player.canGoNext ? root.color2 : root.bg) : root.bg
        implicitWidth: root.buttonWidth; implicitHeight: root.buttonHeight
        border.width: 2; border.color: root.player ? (root.player.canGoNext ? root.color2 : root.color1) : root.color1
        Text { 
          anchors {
            left: parent.left; top: parent.top
            leftMargin: root.buttonLeftMargin; topMargin: root.buttonTopMargin
          }
          text: "⏭"
          font.pixelSize: root.buttonFontSize
          color: root.player ? (root.player.canGoNext ? root.fg : root.fg) : root.fg
        } 
        radius: root.radius
        MouseArea {
          enabled: root.player ? root.player.canGoNext : false
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton
          hoverEnabled: true
          cursorShape: enabled ? Qt.PointingHandCursor : undefined
          onClicked: { root.player.next() }
        }
      }
    }
  }
}