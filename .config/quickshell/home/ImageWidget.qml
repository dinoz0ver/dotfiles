import QtQuick
import Quickshell

Item {
  id: root
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"

  // set this to your image file (local path or URL)
  //property url imagePath: "/home/Dinozover/Pictures/dinosmoking.png"

  //implicitWidth: parent.implicitWidth/2
  //implicitHeight: 220

  Rectangle {
    id: card
    anchors.fill: parent
    radius: 5
    color: root.bg
    clip: true
    border.width: 2; border.color: root.color1

    AnimatedImage {
      id: pic
      anchors.fill: parent
      source: Quickshell.env("HOME") + "/Pictures/dinosleeping.gif"
      asynchronous: true
      fillMode: Image.PreserveAspectFit   // nice cover-style fill
      cache: true
      smooth: true
      playing: true
    }
  }
}