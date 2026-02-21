// ControlCenter.qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Bluetooth
import "../notifs" as Notifs

PopupWindow {
  id: root

  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property int radius: 8

  property bool open: false
  visible: open

  property string currentView: "main"  // "main", "network", or "bluetooth"
  property var seenNetworks: ({})  // Track which networks we've already shown
  property var seenDevices: ({})   // Track which BT devices we've already shown

  onCurrentViewChanged: {
    if (currentView === "network") {
      seenNetworks = {}  // Reset when opening network view
      updateNetworkModel()
    } else if (currentView === "bluetooth") {
      seenDevices = {}  // Reset when opening bluetooth view
      updateBluetoothModel()
    }
  }

  // Network popup state
  property string passwordInputSsid: ""
  property string connectionStatus: ""
  property string lastAttemptedSsid: ""

  // ListModels for proper animations
  ListModel {
    id: networkModel
  }

  ListModel {
    id: bluetoothModel
  }

  // Watch for network changes
  Connections {
    target: Net
    function onNetworksChanged() {
      if (root.currentView === "network") {
        updateNetworkModel()
      }
    }
    function onActiveSsidChanged() {
      if (root.currentView === "network") {
        updateNetworkModel()
      }
    }
  }

  // Watch for bluetooth device changes
  Connections {
    target: Bt.hasAdapter ? Bt.adapter.devices : null
    function onValuesChanged() {
      if (root.currentView === "bluetooth") {
        updateBluetoothModel()
      }
    }
  }

  // Also watch for adapter state changes
  Connections {
    target: Bt.hasAdapter ? Bt.adapter : null
    function onDiscoveringChanged() {
      if (root.currentView === "bluetooth") {
        updateBluetoothModel()
      }
    }
  }

  // Update network model with proper add/remove/move operations
  function updateNetworkModel() {
    if (!Net.hasAdapter) {
      networkModel.clear()
      return
    }

    // Get sorted networks
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
    networks = networks.concat(otherNets)

    // Build map of current model items by SSID
    var currentMap = {}
    for (var j = 0; j < networkModel.count; j++) {
      var item = networkModel.get(j)
      currentMap[item.ssid] = j
    }

    // Build map of new networks by SSID
    var newMap = {}
    for (var k = 0; k < networks.length; k++) {
      newMap[networks[k].ssid] = k
    }

    // Remove items that are no longer in the list
    for (var m = networkModel.count - 1; m >= 0; m--) {
      var oldItem = networkModel.get(m)
      if (!newMap.hasOwnProperty(oldItem.ssid)) {
        networkModel.remove(m)
      }
    }

    // Add new items and move existing ones
    for (var n = 0; n < networks.length; n++) {
      var net = networks[n]
      var ssid = net.ssid || ""

      if (currentMap.hasOwnProperty(ssid)) {
        // Item exists, check if it needs to move
        var currentIndex = -1
        for (var p = 0; p < networkModel.count; p++) {
          if (networkModel.get(p).ssid === ssid) {
            currentIndex = p
            break
          }
        }
        if (currentIndex !== -1 && currentIndex !== n) {
          networkModel.move(currentIndex, n, 1)
        }
        // Update properties in case they changed
        networkModel.set(n, {
          ssid: ssid,
          signal: net.signal
        })
      } else {
        // New item, insert at correct position
        networkModel.insert(n, {
          ssid: ssid,
          signal: net.signal
        })
      }
    }
  }

  // Helper function to find device by address
  function findDevice(address) {
    if (!Bt.hasAdapter) return null
    var devices = Bt.adapter.devices.values
    for (var i = 0; i < devices.length; i++) {
      if (devices[i].address === address || devices[i].name === address) {
        return devices[i]
      }
    }
    return null
  }

  // Update bluetooth model with proper add/remove/move operations
  function updateBluetoothModel() {
    if (!Bt.hasAdapter) {
      bluetoothModel.clear()
      return
    }

    var devices = Bt.adapter.devices.values

    // Build map of current model items by address
    var currentMap = {}
    for (var j = 0; j < bluetoothModel.count; j++) {
      var item = bluetoothModel.get(j)
      currentMap[item.deviceAddress] = j
    }

    // Build map of new devices by address
    var newMap = {}
    for (var k = 0; k < devices.length; k++) {
      var addr = devices[k].address || devices[k].name || ""
      newMap[addr] = k
    }

    // Remove items that are no longer in the list
    for (var m = bluetoothModel.count - 1; m >= 0; m--) {
      var oldItem = bluetoothModel.get(m)
      if (!newMap.hasOwnProperty(oldItem.deviceAddress)) {
        bluetoothModel.remove(m)
      }
    }

    // Add new items and move existing ones
    for (var n = 0; n < devices.length; n++) {
      var dev = devices[n]
      var deviceAddr = dev.address || dev.name || ""

      if (currentMap.hasOwnProperty(deviceAddr)) {
        // Item exists, check if it needs to move
        var currentIndex = -1
        for (var p = 0; p < bluetoothModel.count; p++) {
          if (bluetoothModel.get(p).deviceAddress === deviceAddr) {
            currentIndex = p
            break
          }
        }
        if (currentIndex !== -1 && currentIndex !== n) {
          bluetoothModel.move(currentIndex, n, 1)
        }
        // Update properties
        bluetoothModel.set(n, {
          deviceAddress: deviceAddr,
          deviceName: dev.name || "(unknown)",
          connected: dev.connected || false,
          paired: dev.paired || false,
          bonded: dev.bonded || false,
          pairing: dev.pairing || false,
          state: dev.state
        })
      } else {
        // New item, insert at correct position
        bluetoothModel.insert(n, {
          deviceAddress: deviceAddr,
          deviceName: dev.name || "(unknown)",
          connected: dev.connected || false,
          paired: dev.paired || false,
          bonded: dev.bonded || false,
          pairing: dev.pairing || false,
          state: dev.state
        })
      }
    }
  }

  color: "transparent"
  implicitWidth: 440
  implicitHeight: box.implicitHeight

  anchor.rect.x: 0
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6

  Process {
    id: settingsProc
    command: ["settings-center"]
    running: false
  }

  // Enable keyboard focus for Hyprland when in network view with password input
  HyprlandFocusGrab {
    windows: [root]
    active: root.open && root.currentView === "network" && root.passwordInputSsid !== ""
  }

  Rectangle {
    id: box
    width: parent.width
    height: mainColumn.implicitHeight
    implicitHeight: height
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

    // === MAIN VIEW ===
    Column {
      id: mainColumn
      spacing: 10
      padding: 12
      width: parent.width
      opacity: root.currentView === "main" ? 1.0 : 0.3
      enabled: root.currentView === "main"
      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
      }

      // === HEADER ===
      Item {
        width: parent.width - 24
        height: 44

        Row {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 10

          // Avatar circle
          ClippingRectangle {
            width: 40; height: 40
            radius: 20
            color: root.color1

            Image {
              id: avatarImg
              anchors.fill: parent
              source: "file:///home/dinozover/.config/quickshell/home/profile-icon"
              fillMode: Image.PreserveAspectCrop
              mipmap: true
              visible: status === Image.Ready
            }

            Text {
              anchors.centerIn: parent
              text: ""
              font.pixelSize: 20
              font.family: "Departure Mono"
              color: root.fg
              visible: avatarImg.status !== Image.Ready
            }
          }

          // Username + uptime
          Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
              text: "Dinozover"
              font.pixelSize: 16
              font.family: "Departure Mono"
              font.bold: true
              color: root.fg
            }
            Text {
              text: "uptime " + Uptime.text
              font.pixelSize: 11
              font.family: "Departure Mono"
              color: root.fg
              opacity: 0.7
            }
          }
        }

        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 6

          // DND toggle
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: Notifs.Notifications.dnd ? root.color2 : root.color1

            Text {
              anchors.centerIn: parent
              text: Notifs.Notifications.dnd ? "󰂛" : "󰂚"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifs.Notifications.dnd = !Notifs.Notifications.dnd
            }
          }

          // Settings button
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: root.color1

            Text {
              anchors.centerIn: parent
              text: "\uf013"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: settingsProc.running = true
            }
          }

          // Power button
          Rectangle {
            width: 34; height: 34
            radius: 17
            color: root.color1

            Text {
              anchors.centerIn: parent
              text: "\uf011"
              font.pixelSize: 16
              font.family: "Departure Mono"
              color: root.fg
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: powerPopup.open = !powerPopup.open
            }
          }
        }
      }

      // Separator
      Rectangle {
        width: root.implicitWidth - 24
        height: 1
        color: root.color1
        opacity: 0.3
      }

      // === WIFI + BT CARDS + AUDIO SLIDERS ===
      Row {
        width: parent.width - 24
        spacing: 8

        // Left: wifi and bluetooth stacked
        Column {
          width: parent.width - slidersRow.width - 8
          spacing: 8

          NetworkWidget {
            id: network
            width: parent.width
            bg: root.bg; fg: root.fg
            color1: root.color1; color2: root.color2
            onToggleCenter: root.currentView = "network"
          }

          BluetoothWidget {
            id: bluetooth
            width: parent.width
            bg: root.bg; fg: root.fg
            color1: root.color1; color2: root.color2
            onToggleCenter: root.currentView = "bluetooth"
          }
        }

        // Right: two vertical sliders side by side
        Row {
          id: slidersRow
          spacing: 6
          height: parent.height

          // Output volume slider
          Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Slider {
              id: outputSlider
              orientation: Qt.Vertical
              from: 0; to: 100
              implicitHeight: 108
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

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (Audio.sink?.audio?.muted ?? false) ? "󰖁" : "󰕾"
              font.pixelSize: 16
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
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Slider {
              id: micSlider
              orientation: Qt.Vertical
              from: 0; to: 100
              implicitHeight: 108
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

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: (Audio.source?.audio?.muted ?? false) ? "󰍭" : "󰍬"
              font.pixelSize: 16
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

      // Separator
      Rectangle {
        width: root.implicitWidth - 24
        height: 1
        color: root.color1
        opacity: 0.3
      }

      // === MEDIA PLAYER ===
      PlayerWidget {
        id: player
        implicitWidth: parent.width - 24
        bg: root.bg; fg: root.fg
        color1: root.color1; color2: root.color2
      }
    }

    // === NETWORK VIEW ===
    Item {
      id: networkViewContainer
      width: parent.width
      height: parent.height

      Rectangle {
        id: networkView
        width: parent.width
        height: parent.height
        radius: root.radius
        color: root.bg
        border.width: 2
        border.color: root.fg
        transformOrigin: Item.Top
        scale: root.currentView === "network" ? 1.0 : 0.1
        y: root.currentView === "network" ? 0 : 80
        opacity: root.currentView === "network" ? 1.0 : 0.0
        Behavior on scale {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }
        Behavior on y {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }

      Column {
        anchors.fill: parent
        spacing: 6
        padding: 6

      Rectangle {
        id: networkHeader
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.bg
        z: 1000
        Row {
          spacing: 6
          Rectangle {
            implicitWidth: backBtnText.implicitWidth
            implicitHeight: 26
            color: root.fg
            radius: 4
            Text {
              id: backBtnText
              padding: 6
              text: "← Back"
              color: root.bg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentView = "main"
                root.passwordInputSsid = ""
                root.connectionStatus = ""
              }
            }
          }
          Text {
            id: networkHeaderText
            padding: 4
            font.pixelSize: 16
            font.family: "Departure Mono"
            text: "Wifi"
            color: root.fg
          }
          Rectangle {
            implicitWidth: root.implicitWidth-12-backBtnText.implicitWidth-networkHeaderText.implicitWidth-onOffText.implicitWidth-refreshText.implicitWidth-5*6
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
        id: networkList
        height: parent.height - networkHeader.height - 12
        width: parent.width-12
        model: networkModel
        spacing: 6

        add: Transition {
          SequentialAnimation {
            PropertyAction { property: "opacity"; value: 0 }
            NumberAnimation { property: "opacity"; to: 1.0; duration: 400; easing.type: Easing.OutCubic }
          }
        }
        move: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }
        displaced: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }
        remove: Transition {
          NumberAnimation { property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic }
        }
        removeDisplaced: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }

        delegate: Rectangle {
          id: networkDelegate
          width: networkList.width
          height: root.passwordInputSsid === model.ssid ? (root.connectionStatus !== "" ? 92 : 72) : 36
          color: root.bg
          radius: root.radius
          border.color: root.color1
          border.width: 2

          property bool shouldAnimate: false
          opacity: shouldAnimate ? 0 : 1

          Behavior on opacity {
            enabled: shouldAnimate
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
          }

          Component.onCompleted: {
            var ssid = model.ssid || ""
            if (ssid && !root.seenNetworks[ssid]) {
              // This is a new network we haven't seen before
              shouldAnimate = true
              var newSeen = root.seenNetworks
              newSeen[ssid] = true
              root.seenNetworks = newSeen
              Qt.callLater(function() { opacity = 1 })
            }
          }

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
                text: (model.signal <= 25 ? "󰤟" : (model.signal <= 50 ? "󰤢" : (model.signal <= 75 ? "󰤥" : "󰤨")))+" "+(model.ssid || "(hidden)")
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
                  text: (Net.activeSsid === model.ssid)
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
                    if (Net.activeSsid === model.ssid) {
                      Net.disconnect()
                      root.passwordInputSsid = ""
                      root.connectionStatus = ""
                    } else {
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = model.ssid
                      Net.connect(model.ssid)
                      statusTimer.ssid = model.ssid
                      statusTimer.restart()
                    }
                  }
                }
              }
            }

            Row {
              width: parent.width
              height: 26
              spacing: 6
              visible: root.passwordInputSsid === model.ssid

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
                    if (root.passwordInputSsid === model.ssid) {
                      root.connectionStatus = ""
                    }
                  }

                  Component.onCompleted: {
                    if (root.passwordInputSsid === model.ssid) {
                      forceActiveFocus()
                    }
                  }

                  onAccepted: {
                    if (text.length > 0) {
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = model.ssid
                      Net.connect(model.ssid, text)
                      statusTimer.ssid = model.ssid
                      statusTimer.restart()
                    }
                  }
                }

                Connections {
                  target: root
                  function onPasswordInputSsidChanged() {
                    if (root.passwordInputSsid === model.ssid) {
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
                      root.lastAttemptedSsid = model.ssid
                      Net.connect(model.ssid, passwordInput.text)
                      statusTimer.ssid = model.ssid
                      statusTimer.restart()
                    } else {
                      root.connectionStatus = "Connecting..."
                      root.lastAttemptedSsid = model.ssid
                      Net.connect(model.ssid)
                      statusTimer.ssid = model.ssid
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

            Row {
              width: parent.width
              height: 16
              visible: root.passwordInputSsid === model.ssid && root.connectionStatus !== ""

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
          width: networkList.width; height: 28
          horizontalAlignment: Text.AlignHCenter
          font.family: "Departure Mono"
          text: !Net.hasAdapter ? "No adapter" :
             ((Net.hasAdapter && Net.online) ? (networkList.count === 0 ? "No networks (refresh?)" : "") : "Turn on wifi?")
          visible: (text !== "")
          color: root.fg
        }
      }
      }
      }
    }

    // === BLUETOOTH VIEW ===
    Item {
      id: bluetoothViewContainer
      width: parent.width
      height: parent.height

      Rectangle {
        id: bluetoothView
        width: parent.width
        height: parent.height
        radius: root.radius
        color: root.bg
        border.width: 2
        border.color: root.fg
        transformOrigin: Item.Top
        scale: root.currentView === "bluetooth" ? 1.0 : 0.1
        y: root.currentView === "bluetooth" ? 0 : 150
        opacity: root.currentView === "bluetooth" ? 1.0 : 0.0
        Behavior on scale {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }
        Behavior on y {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }
        Behavior on opacity {
          NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
        }

      Column {
        anchors.fill: parent
        spacing: 6
        padding: 6

      Rectangle {
        id: btHeader
        implicitWidth: parent.width-12
        implicitHeight: 30
        color: root.bg
        z: 1000
        Row {
          spacing: 6
          Rectangle {
            implicitWidth: btBackBtnText.implicitWidth
            implicitHeight: 26
            color: root.fg
            radius: 4
            Text {
              id: btBackBtnText
              padding: 6
              text: "← Back"
              color: root.bg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.currentView = "main"
            }
          }
          Text {
            id: btHeaderText
            padding: 4
            font.pixelSize: 16
            font.family: "Departure Mono"
            text: "Bluetooth"
            color: root.fg
          }
          Rectangle {
            implicitWidth: root.implicitWidth-btOnOffText.implicitWidth-btScanText.implicitWidth-btHeaderText.implicitWidth-btBackBtnText.implicitWidth-6*4-12
            implicitHeight: 26
            color: "transparent"
          }
          Rectangle {
            implicitWidth: btOnOffText.implicitWidth
            implicitHeight: 26
            color: root.fg
            radius: 4
            visible: Bt.hasAdapter
            Text {
              id: btOnOffText
              padding: 6
              text: (Bt.hasAdapter && Bt.adapter.enabled) ? "Off" : "On"
              color: root.bg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Bt.hasAdapter) Bt.adapter.enabled = !Bt.adapter.enabled
            }
          }
          Rectangle {
            implicitWidth: btScanText.implicitWidth
            implicitHeight: 26
            color: enabled ? root.fg : root.color1
            enabled: Bt.hasAdapter && Bt.adapter.enabled
            radius: 4
            border.width: 2; border.color: root.fg
            visible: Bt.hasAdapter
            Text {
              id: btScanText
              padding: 6
              text: (Bt.hasAdapter && Bt.adapter.discovering) ? "Stop scan" : "Scan"
              color: parent.enabled ? root.color1 : root.fg
              font.family: "Departure Mono"
            }
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (Bt.hasAdapter) Bt.adapter.discovering = !Bt.adapter.discovering
            }
          }
        }
      }

      ListView {
        id: btList
        width: parent.width - 12
        height: parent.height - btHeader.height - 12
        model: bluetoothModel
        spacing: 6

        add: Transition {
          SequentialAnimation {
            PropertyAction { property: "opacity"; value: 0 }
            NumberAnimation { property: "opacity"; to: 1.0; duration: 400; easing.type: Easing.OutCubic }
          }
        }
        move: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }
        displaced: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }
        remove: Transition {
          NumberAnimation { property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic }
        }
        removeDisplaced: Transition {
          NumberAnimation { properties: "x,y"; duration: 500; easing.type: Easing.OutCubic }
        }

        delegate: Rectangle {
          id: btDelegate
          width: btList.width
          height: 40
          color: root.bg
          radius: root.radius
          border.color: root.color1
          border.width: 2

          property bool shouldAnimate: false
          opacity: shouldAnimate ? 0 : 1

          Behavior on opacity {
            enabled: shouldAnimate
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
          }

          Component.onCompleted: {
            var deviceId = model.deviceAddress || ""
            if (deviceId && !root.seenDevices[deviceId]) {
              // This is a new device we haven't seen before
              shouldAnimate = true
              var newSeen = root.seenDevices
              newSeen[deviceId] = true
              root.seenDevices = newSeen
              Qt.callLater(function() { opacity = 1 })
            }
          }

          Row {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6
            Text {
              id: deviceNameText
              text: model.deviceName
              padding: 6
              color: root.fg
              font.family: "Departure Mono"
            }
            Rectangle {
              width: parent.width - deviceNameText.implicitWidth - connectButton.width - (model.bonded ? forgetButton.width + 6 : 0) - 6*2
              height: 26
              color: "transparent"
            }
            Rectangle {
              id: connectButton
              width: Math.max(connectText.implicitWidth + 12, 80)
              height: 26
              color: root.color1
              readonly property bool busy: model.pairing || model.state === BluetoothDeviceState.Connecting || model.state === BluetoothDeviceState.Disconnecting
              enabled: Bt.hasAdapter && Bt.adapter.enabled && !busy
              radius: 4
              Text {
                id: connectText
                anchors.fill: parent
                text: parent.busy ? "Working…" : (model.connected ? "Disconnect" : (model.paired ? "Connect" : "Pair"))
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
                  if (parent.busy) return
                  var device = root.findDevice(model.deviceAddress)
                  if (!device) return
                  if (model.connected) device.disconnect()
                  else if (model.paired) device.connect()
                  else device.pair()
                }
              }
            }
            Rectangle {
              id: forgetButton
              width: Math.max(forgetText.implicitWidth + 12, 70)
              height: 26
              color: root.color1
              enabled: Bt.hasAdapter && Bt.adapter.enabled
              visible: model.bonded
              radius: 4
              Text {
                id: forgetText
                anchors.fill: parent
                text:"Forget"
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
                  var device = root.findDevice(model.deviceAddress)
                  if (device) device.forget()
                }
              }
            }
          }
        }

        ScrollBar.vertical: ScrollBar {}
        footer: Text {
          width: btList.width; height: 28
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          topPadding: 8
          color: root.fg
          font.family: "Departure Mono"
          text: !Bt.hasAdapter ? "No adapter" :
             ((Bt.hasAdapter && Bt.adapter.discovering) ? "Scanning…" :
             (btList.count === 0 ? "No devices" : ""))
          visible: text !== ""
        }
      }
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
        root.connectionStatus = "Connected!"
        root.passwordInputSsid = ""
        Qt.callLater(function() {
          root.connectionStatus = ""
        })
      } else if (root.lastAttemptedSsid === ssid) {
        if (root.passwordInputSsid === ssid) {
          root.connectionStatus = "Failed - incorrect password?"
        } else {
          root.connectionStatus = ""
          root.passwordInputSsid = ssid
        }
      }
    }
  }

  // === SUB-POPUPS ===
  PowerPopup {
    id: powerPopup
    anchor.window: root
    bg: root.bg; fg: root.fg
    color1: root.color1; color2: root.color2
    anchor.rect.x: root.implicitWidth - 180
    anchor.rect.y: 6 + root.height
  }
}
