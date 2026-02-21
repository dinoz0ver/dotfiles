// NetworkPopup.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property bool open: false
  property int radius: 8
  property string passwordInputSsid: ""
  property string connectionStatus: ""
  property string lastAttemptedSsid: ""

  // Sorted networks with connected network first
  property var sortedNetworks: {
    if (!Net.hasAdapter) return []
    var networks = []
    var connectedNet = null
    var otherNets = []

    for (var i = 0; i < Net.networks.length; i++) {
      var network = Net.networks[i]
      if (Net.activeSsid === network.ssid) {
        connectedNet = network
      } else {
        otherNets.push(network)
      }
    }

    if (connectedNet) {
      networks.push(connectedNet)
    }
    return networks.concat(otherNets)
  }

  implicitWidth: 440
  implicitHeight: 220
  color: "transparent"
  visible: open

  // Enable keyboard focus for Hyprland
  HyprlandFocusGrab {
    windows: [root]
    active: root.open && root.passwordInputSsid !== ""
  }

  Rectangle {
    width: parent.width
    height: parent.height
    radius: root.radius
    color: root.bg
    border.width: 2; border.color: root.fg

    y: root.open ? 0 : -20
    Behavior on y {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    opacity: root.open ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Column {
      anchors.fill: parent
      spacing: 6
      padding: 6

      Rectangle {
        id: header
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.bg
        z: 1000
        Row {
          spacing: 6
          Text {
            id: headerText
            padding: 4
            font.pixelSize: 16
      font.family: "Departure Mono"
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
            visible: Net.hasAdapter
            Text {
              id: onOffText
              padding: 6
              text: (Net.hasAdapter && Net.online) ? "Off" : "On"
              color: root.bg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Net.hasAdapter) Net.setWifiEnabled(!Net.online)
            }
          }
          Rectangle {
            implicitWidth: refreshText.implicitWidth
            implicitHeight: 26
            enabled: Net.hasAdapter && Net.online
            color: enabled ? root.fg : root.color1
            radius: 4
            border.width: 2; border.color: root.fg
            visible: Net.hasAdapter
            Text {
              id: refreshText
              padding: 6
              text: "Refresh"
              color: parent.enabled ? root.color1 : root.fg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Net.hasAdapter) Net.refresh()
            }
          }
        }
      }
      ListView {
        id: list
        height: parent.height - header.height-12
        width: parent.width-12
        model: root.sortedNetworks
        spacing: 6

        delegate: Rectangle {
          width: list.width
          height: root.passwordInputSsid === modelData.ssid ? (root.connectionStatus !== "" ? 92 : 72) : 36
          color: root.bg
          radius: root.radius
          border.color: root.color1
          border.width: 2

          Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            Row {
              width: parent.width
              height: 26
              spacing: 8

              Text {
                id: networkNameText
                padding: 5
                color: root.fg
                text: (modelData.signal <= 25 ? "󰤟" : (modelData.signal <= 50 ? "󰤢" : (modelData.signal <= 75 ? "󰤥" : "󰤨")))+" "+(modelData.ssid || "(hidden)")
                font.family: "Departure Mono"
              }
              Rectangle {
                width: parent.width - networkNameText.implicitWidth - connectDisconnectButton.width - 16
                height: 26
                color: "transparent"
              }
              Rectangle {
                id: connectDisconnectButton
                width: Math.max(connectDisconnectText.implicitWidth + 12, 80)
                height: 26
                color: root.color1
                radius: 4
                Text {
                  id: connectDisconnectText
                  anchors.fill: parent
                  text: (Net.activeSsid === modelData.ssid)
                    ? "Disconnect" : "Connect"
                  color: root.fg
                  font.family: "Departure Mono"
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked:  {
                    if (Net.activeSsid === modelData.ssid) {
                      Net.disconnect()
                      root.passwordInputSsid = ""
                      root.connectionStatus = ""
                    } else {
                      // Try connecting without password first (for saved networks)
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = modelData.ssid
                      Net.connect(modelData.ssid)
                      // Check connection status after a delay
                      statusTimer.ssid = modelData.ssid
                      statusTimer.restart()
                    }
                  }
                }
              }
            }

            // Password input row
            Row {
              width: parent.width
              height: 26
              spacing: 6
              visible: root.passwordInputSsid === modelData.ssid

              Rectangle {
                width: 280
                height: 26
                color: root.bg
                border.width: 1
                border.color: root.color1
                radius: 4

                TextInput {
                  id: passwordInput
                  anchors.fill: parent
                  anchors.margins: 4
                  color: root.fg
                  font.family: "Departure Mono"
                  font.pixelSize: 12
                  echoMode: TextInput.Password
                  verticalAlignment: TextInput.AlignVCenter
                  focus: true
                  activeFocusOnPress: true

                  onTextChanged: {
                    // Clear error when user starts typing
                    if (root.passwordInputSsid === modelData.ssid) {
                      root.connectionStatus = ""
                    }
                  }

                  Component.onCompleted: {
                    if (root.passwordInputSsid === modelData.ssid) {
                      forceActiveFocus()
                    }
                  }

                  onAccepted: {
                    if (text.length > 0) {
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = modelData.ssid
                      Net.connect(modelData.ssid, text)
                      // Check connection status after a delay
                      statusTimer.ssid = modelData.ssid
                      statusTimer.restart()
                    }
                  }
                }

                Connections {
                  target: root
                  function onPasswordInputSsidChanged() {
                    if (root.passwordInputSsid === modelData.ssid) {
                      passwordInput.forceActiveFocus()
                    }
                  }
                }
              }

              Rectangle {
                width: Math.max(submitText.implicitWidth + 12, 70)
                height: 26
                color: root.color1
                radius: 4
                Text {
                  id: submitText
                  anchors.fill: parent
                  text: "Submit"
                  color: root.fg
                  font.family: "Departure Mono"
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (passwordInput.text.length > 0) {
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = modelData.ssid
                      Net.connect(modelData.ssid, passwordInput.text)
                      // Check connection status after a delay
                      statusTimer.ssid = modelData.ssid
                      statusTimer.restart()
                    } else {
                      // Try connecting without password
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = modelData.ssid
                      Net.connect(modelData.ssid)
                      statusTimer.ssid = modelData.ssid
                      statusTimer.restart()
                    }
                  }
                }
              }

              Rectangle {
                width: Math.max(cancelText.implicitWidth + 12, 70)
                height: 26
                color: root.bg
                border.width: 1
                border.color: root.color1
                radius: 4
                Text {
                  id: cancelText
                  anchors.fill: parent
                  text: "Cancel"
                  color: root.fg
                  font.family: "Departure Mono"
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                }
                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.passwordInputSsid = ""
                    root.connectionStatus = ""
                    passwordInput.text = ""
                  }
                }
              }
            }

            // Status message row
            Row {
              width: parent.width
              height: 16
              visible: root.passwordInputSsid === modelData.ssid && root.connectionStatus !== ""

              Text {
                padding: 2
                color: root.connectionStatus.includes("Failed") || root.connectionStatus.includes("incorrect") ? "#ff0000" : root.fg
                text: root.connectionStatus
                font.family: "Departure Mono"
                font.pixelSize: 11
              }
            }
          }
        }
        ScrollBar.vertical: ScrollBar {}
        footer: Text {
          width: list.width; height: 28
          horizontalAlignment: Text.AlignHCenter
          font.family: "Departure Mono"
          text: !Net.hasAdapter ? "No adapter" :
             ((Net.hasAdapter && Net.online) ? (list.count === 0 ? "No networks (refresh?)" : "") : "Turn on wifi?")
          visible: (text !== "")
          color: root.fg
        }
      }
    }
  }

  // Timer to check connection status
  Timer {
    id: statusTimer
    property string ssid: ""
    interval: 3000
    repeat: false
    onTriggered: {
      if (Net.activeSsid === ssid) {
        // Connection successful
        root.connectionStatus = "Connected!"
        root.passwordInputSsid = ""
        // Clear status after a short delay
        Qt.callLater(function() {
          root.connectionStatus = ""
        })
      } else if (root.lastAttemptedSsid === ssid) {
        // Connection failed - show password input if not already shown
        if (root.passwordInputSsid === ssid) {
          // Password was entered but still failed
          root.connectionStatus = "Failed - incorrect password?"
        } else {
          // No password was entered, network probably needs one
          root.connectionStatus = ""
          root.passwordInputSsid = ssid
        }
      }
    }
  }
}