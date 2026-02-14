// Notifications.qml
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications
import Quickshell

Singleton {
  id: api
  
  property int maxVisible: 3
  property int autoCloseMs: 5000
  property var hidden: []
  function hide(n) { hidden = hidden.concat([n]); }
  function clearHidden() { hidden = []; }

  NotificationServer {
    id: srv
    keepOnReload: false // should probably set to false bc after reload popups break without a reason
    actionsSupported: true
    actionIconsSupported: true
    //imageSupported: true
    onNotification: (n) => {
      console.log("[notify-send]", n.appName, "-", n.summary)
      n.tracked = true      // persist only non-transient
    }
  }

  readonly property var model: srv.trackedNotifications
  readonly property int count: model ? model.values.length : 0
  readonly property var visibleValues: model ? model.values.filter(v => api.hidden.indexOf(v) === -1).slice(0, maxVisible) : []
  function clearAll() {
    for (let i = count; i > 0; i--) {
      //console.log(i, count)
      model.values[0].tracked = false
    }
  }
}
