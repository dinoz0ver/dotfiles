// Bt.qml
pragma Singleton
import QtQuick
import Quickshell.Bluetooth
import Quickshell

Singleton {
  // expose the default adapter from Quickshell’s Bluetooth singleton
  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property int devicesCount: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.devices ? Bluetooth.defaultAdapter.devices.values.length : 0) : 0
  readonly property int connectedCount: {
    let cnt = 0
    if (!adapter)
      return 0
    if (adapter.devices) {
      for (let dev of adapter.devices.values) {
        if ( dev.connected )
          cnt++
      }
      return cnt
    }
    return 0
  }
}