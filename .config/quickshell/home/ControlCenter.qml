// ControlCenter.qml
import QtQuick
import Quickshell
import Quickshell.Widgets

PopupWindow {
  id: root
  
  property color bg: "#000000"
  property color fg: "#ffffff"
  property color color1: "#ff0000"
  property color color2: "#ffff00"
  property int radius: 5

  property bool open: false
  visible: open
  color: "transparent"
  implicitWidth: 440
  implicitHeight: 400

  anchor.rect.x: 0
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6

  Rectangle {
    id: box
    anchors.fill: parent
    radius: root.radius
    color: root.bg 
    border.width: 2; border.color: root.fg
    Column {
      spacing: 6
      padding: 6
      Row {
        spacing: 6
        Text {
          padding: 3
          id: homeText
          text: "Dinozover's home" //"ඞ's home"
          color: root.fg
          font.pixelSize: 20
        }
        Item {
          implicitWidth: root.implicitWidth-homeText.implicitWidth-shutdown.implicitWidth-reboot.implicitWidth-30
          implicitHeight: 34
        }
        ShutdownWidget {
          id: shutdown
          bg: root.fg
          fg: root.bg
        }
        RebootWidget {
          id: reboot
          bg: root.fg
          fg: root.bg
        }
      }
      Row {
        spacing: 6
        BluetoothWidget {
          id: bluetooth
          implicitWidth: root.implicitWidth/2-9
          bg: root.bg
          fg: root.fg
          color1: root.color1
          color2: root.color2
          onToggleCenter: {bluetoothPopup.open = !bluetoothPopup.open; networkPopup.open = false}
        }
        BluetoothPopup {
          id: bluetoothPopup
          anchor.window: root
          bg: root.bg
          fg: root.fg
          color1: root.color1
          anchor.rect.x: 0
          anchor.rect.y: 6+root.height
        }
        NetworkWidget {
          id: network
          implicitWidth: root.implicitWidth/2-9
          bg: root.bg
          fg: root.fg
          color1: root.color1
          color2: root.color2
          onToggleCenter: {networkPopup.open = !networkPopup.open; bluetoothPopup.open = false}
        }
        NetworkPopup {
          id: networkPopup
          anchor.window: root
          bg: root.bg
          fg: root.fg
          color1: root.color1
          anchor.rect.x: 0
          anchor.rect.y: 6+root.height
        }
      }
      Row {
        spacing: 6
        CpuWidget {
          id: cpu
          bg: root.bg
          fg: root.fg
          color1: root.color1
          implicitWidth: root.implicitWidth/4-7.5
        }
        MemWidget {
          id: mem
          bg: root.bg
          fg: root.fg
          color1: root.color1
          implicitWidth: root.implicitWidth/4-7.5
        }
        StorageWidget {
          id: storage
          bg: root.bg
          fg: root.fg
          color1: root.color1
          implicitWidth: root.implicitWidth/4-7.5
        }
        GpuWidget {
          id: gpu
          bg: root.bg
          fg: root.fg
          color1: root.color1
          implicitWidth: root.implicitWidth/4-7.5
        }
      }
      Row {
        PlayerWidget {
          id: player
          implicitWidth: root.implicitWidth-12
          bg: root.bg
          fg: root.fg
          color1: root.color1
          color2: root.color2
        }
      }
      Row {
        AudioWidget {
          id: audio
          implicitWidth: root.implicitWidth-12
          bg: root.bg
          fg: root.fg
          color1: root.color1
          color2: root.color2
        }
      }
      Row {
        spacing: 6
        CalendarWidget {
          id: calendar
          implicitWidth: root.implicitWidth/2-10
          bg: root.bg
          fg: root.fg
          color1: root.color1
        }
        ImageWidget {
          id: image
          implicitWidth: root.implicitWidth/2-10
          implicitHeight: calendar.implicitHeight
          bg: root.bg
          fg: root.fg
          color1: root.color1
        }
      }
    }
  }
}
