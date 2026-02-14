// NetworkPopup.qml
import QtQuick
import QtQuick.Controls
import Quickshell
// to do: add password input, make list objects unload beautifully, not like it is now

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property bool open: false
  property int radius: 5

  implicitWidth: 440
  implicitHeight: 220
  color: "transparent"
  visible: open

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.color1
    border.width: 2; border.color: root.fg

    Column {
      anchors.fill: parent
      spacing: 6
      padding: 6

      Rectangle {
        id: header
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.color1
        z: 1000
        Row {
          spacing: 6
          Text {
            id: headerText
            padding: 4
            font.pixelSize: 16
            text: "Wifi"
            color: root.fg
          }
          Rectangle {
            implicitWidth: root.implicitWidth-12-headerText.implicitWidth-onOffText.implicitWidth-refreshText.implicitWidth-3*6
            implicitHeight: 30
            color: "transparent"
          }
          Rectangle {
            implicitWidth: onOffText.implicitWidth
            implicitHeight: 26
            color: root.fg
            radius: 4
            Text { 
              id: onOffText
              padding: 6
              text: Net.online ? "Off" : "On"
              color: root.bg 
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Net.setWifiEnabled(!Net.online)
            }
          }
          Rectangle {
            implicitWidth: refreshText.implicitWidth
            implicitHeight: 26
            enabled: Net.online
            color: enabled ? root.fg : root.color1
            radius: 4
            border.width: 2; border.color: root.fg
            Text { 
              id: refreshText
              padding: 6
              text: "Refresh"
              color: parent.enabled ? root.color1 : root.fg 
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Net.refresh() 
            }
          }
        }
      }
      ListView {
        id: list
        height: parent.height - header.height-12
        width: parent.width-12
        model: Net.networks
        spacing: 6

        delegate: Rectangle {
          width: list.width
          height: 36
          color: root.fg
          radius: root.radius
          Row {
            anchors.fill: parent; anchors.margins: 6; spacing: 8

            Text {
              padding: 5
              color: root.bg
              text: (modelData.signal <= 25 ? "󰤟" : (modelData.signal <= 50 ? "󰤢" : (modelData.signal <= 75 ? "󰤥" : "󰤨")))+" "+(modelData.ssid || "(hidden)") 
              width: (modelData.inUse ? 321 : 344)
            }
            Rectangle {
              implicitWidth: connectDisconnectText.implicitWidth
              implicitHeight: 26
              color: root.color1
              radius: 4
              Text { 
                id: connectDisconnectText
                padding: 6
                text: (Net.activeSsid === modelData.ssid)
                  ? "Disconnect" : "Connect"
                color: root.fg 
              }
              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:  {
                  if (Net.activeSsid === modelData.ssid)
                    {Net.disconnect(); console.log(Net.activeSsid)}
                  else
                    // For WPA networks, pass a password:
                    // Net.connect(model.ssid, "your-password")
                    Net.connect(modelData.ssid)
                }
              }
            }
            //Button {
            //  text: (Net.activeSsid === modelData.ssid && Net.online)
            //      ? "Disconnect" : "Connect"
            //  onClicked: {
            //    if (Net.activeSsid === modelData.ssid && Net.online)
            //      Net.disconnect()
            //    else
            //      // For WPA networks, pass a password:
            //      // Net.connect(model.ssid, "your-password")
            //      Net.connect(modelData.ssid)
            //  }
            //}
          }
        }
        ScrollBar.vertical: ScrollBar {}
        footer: Text {
          width: list.width; height: 28
          horizontalAlignment: Text.AlignHCenter
          text: Net.online ? (list.count === 0 ? "No networks (refresh?)" : "") : "Turn on wifi?"
          visible: (text !== "")
          color: root.fg
        }
      }
    }
  }
}