// AudioWidget.qml
import QtQuick
import QtQuick.Controls

Item {
  id: root

  property int radius: 8
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"

  property int sliderHeight: 140

  implicitHeight: sliderHeight + 40

  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 20

    // Output volume slider
    Column {
      spacing: 6

      Slider {
        id: outputSlider
        orientation: Qt.Vertical
        from: 0; to: 100
        implicitHeight: root.sliderHeight
        implicitWidth: 28
        value: Math.round((Audio.sink?.audio?.volume ?? 0) * 100)
        onMoved: Audio.setVolume(value, true)

        background: Rectangle {
          x: outputSlider.leftPadding + outputSlider.availableWidth / 2 - width / 2
          y: outputSlider.topPadding
          implicitWidth: 8
          implicitHeight: outputSlider.availableHeight
          width: implicitWidth
          height: outputSlider.availableHeight
          radius: 4
          color: root.color1

          Rectangle {
            width: parent.width
            height: (1.0 - outputSlider.visualPosition) * parent.height
            y: outputSlider.visualPosition * parent.height
            color: root.color2
            radius: 4
          }
        }

        handle: Rectangle {
          x: outputSlider.leftPadding + outputSlider.availableWidth / 2 - width / 2
          y: outputSlider.topPadding + outputSlider.visualPosition * (outputSlider.availableHeight - height)
          implicitWidth: 18
          implicitHeight: 18
          radius: 9
          color: root.fg
        }
      }

      // Speaker icon (mute toggle)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: (Audio.sink?.audio?.muted ?? false) ? "󰖁" : "󰕾"
        font.pixelSize: 18
        font.family: "Departure Mono"
        color: root.fg

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: Audio.toggleMute(true)
        }
      }
    }

    // Mic volume slider
    Column {
      spacing: 6

      Slider {
        id: micSlider
        orientation: Qt.Vertical
        from: 0; to: 100
        implicitHeight: root.sliderHeight
        implicitWidth: 28
        value: Math.round((Audio.source?.audio?.volume ?? 0) * 100)
        onMoved: Audio.setVolume(value, false)

        background: Rectangle {
          x: micSlider.leftPadding + micSlider.availableWidth / 2 - width / 2
          y: micSlider.topPadding
          implicitWidth: 8
          implicitHeight: micSlider.availableHeight
          width: implicitWidth
          height: micSlider.availableHeight
          radius: 4
          color: root.color1

          Rectangle {
            width: parent.width
            height: (1.0 - micSlider.visualPosition) * parent.height
            y: micSlider.visualPosition * parent.height
            color: root.color2
            radius: 4
          }
        }

        handle: Rectangle {
          x: micSlider.leftPadding + micSlider.availableWidth / 2 - width / 2
          y: micSlider.topPadding + micSlider.visualPosition * (micSlider.availableHeight - height)
          implicitWidth: 18
          implicitHeight: 18
          radius: 9
          color: root.fg
        }
      }

      // Mic icon (mute toggle)
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: (Audio.source?.audio?.muted ?? false) ? "󰍭" : "󰍬"
        font.pixelSize: 18
        font.family: "Departure Mono"
        color: root.fg

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: Audio.toggleMute(false)
        }
      }
    }
  }
}
