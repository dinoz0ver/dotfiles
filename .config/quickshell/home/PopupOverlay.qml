// PopupOverlay.qml
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: overlay

  property bool active: false
  signal clicked()

  visible: active
  color: "transparent"

  // Anchor to all edges to make it fullscreen
  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  // Don't reserve exclusive space
  exclusionMode: ExclusionMode.Ignore

  // Use Overlay layer to receive mouse events
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onClicked: {
      console.log("Overlay clicked!")
      overlay.clicked()
    }
  }
}
