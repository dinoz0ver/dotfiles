import QtQuick
import Quickshell.Services.UPower

Item {
  id: root

  property int heightBox: 34
  property int widthMargin: 10
  property int heightMargin: 7
  property int radius: 5
  property int fontSize: 14

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#d1ac02"

  implicitWidth: box.implicitWidth
  implicitHeight: box.implicitHeight

  readonly property bool ready: UPower.displayDevice.ready
  readonly property int percent: ready ? Math.round(UPower.displayDevice.percentage*100) : -1
  readonly property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged
  readonly property bool hasBattery: UPower.displayDevice.isPowerSupply ?? false

  // Hide widget if no battery detected
  // Note: isPowerSupply doesn't work reliably, so we check if percent is valid instead
  visible: ready && percent >= 0

  function levelIcon(p) {
    if (p < 0)      return ""; // unknown -> show empty
    if (p <= 5)     return ""; // empty
    if (p <= 25)    return ""; // quarter
    if (p <= 50)    return ""; // half
    if (p <= 75)    return ""; // three-quarters
    return "";                 // full
  }

  Rectangle {
    id: box
    anchors {
      right: parent.right; top: parent.top
    }
    implicitWidth: icon.implicitWidth + 2*root.widthMargin
    implicitHeight: root.heightBox
    radius: root.radius
    color: root.bg
    Text {
      id: icon
      anchors {
        right: parent.right; top: parent.top
        rightMargin: root.widthMargin; topMargin: root.heightMargin
      }
      text: levelIcon(root.percent)+" "+root.percent+"%"
      color: root.fg
      font.pixelSize: root.fontSize
      font.family: "Departure Mono"
    }
    Text {
      id: chargeIcon
      anchors {
        left: parent.left; top: parent.top
        leftMargin: root.widthMargin+2; topMargin: root.heightMargin
      }
      visible: root.charging
      text: " "
      color: root.color1
      font.pixelSize: root.fontSize
      font.family: "Departure Mono"
    }
  }
}
