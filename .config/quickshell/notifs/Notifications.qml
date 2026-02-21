// Notifications.qml
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications
import Quickshell
import Quickshell.Io

Singleton {
  id: api

  property bool dnd: false
  property int maxVisible: 3
  property int autoCloseMs: 5000
  property var hidden: []

  // Persistent notification data — survives app-initiated closes
  property var savedNotifications: []
  property int savedCount: savedNotifications.length

  // Popup queue - newest first, oldest last
  // Slots may contain null (dismissed) to prevent cascading shifts
  property var popupQueue: []

  // Per-notification timer tracking (independent of popup position)
  property var _showTimes: ({})  // {notifId: timestamp when first shown}
  property var _pausedAt: ({})   // {notifId: timestamp when hover started}
  property var _pendingDismiss: []  // notification ids awaiting animated dismiss
  property int _lastEnqueuedId: -1  // id of the most recently enqueued notification

  // Centralized auto-dismiss: checks every 200ms, dismisses oldest expired first
  Timer {
    id: autoDismissChecker
    interval: 200
    repeat: true
    running: api.popupQueue.length > 0
    onTriggered: {
      var now = Date.now()
      var oldestExpired = null
      var oldestTime = Infinity
      for (var i = 0; i < api.popupQueue.length; i++) {
        var n = api.popupQueue[i]
        if (n && api._showTimes[n.id] && !api._pausedAt[n.id] && api._pendingDismiss.indexOf(n.id) < 0) {
          if (now - api._showTimes[n.id] >= api.autoCloseMs) {
            if (api._showTimes[n.id] < oldestTime) {
              oldestTime = api._showTimes[n.id]
              oldestExpired = n
            }
          }
        }
      }
      if (oldestExpired) {
        console.log("[Timer] Auto-dismissing oldest notif", oldestExpired.id)
        api.requestDismiss(oldestExpired)
      }
    }
  }

  // Request animated dismiss - popup will detect this and animate out before calling hide()
  function requestDismiss(n) {
    if (!n) return
    if (_pendingDismiss.indexOf(n.id) < 0) {
      _pendingDismiss = _pendingDismiss.concat([n.id])
      console.log("[Queue] Requested dismiss for notif", n.id)
    }
  }

  // Actually remove notification (called by popup after animation completes)
  function hide(n) {
    _pendingDismiss = _pendingDismiss.filter(function(id) { return id !== n.id })
    // Replace with null instead of filtering - prevents cascading shifts
    var newQueue = popupQueue.map(item => item === n ? null : item)
    // If all slots are null, clear the queue entirely
    if (newQueue.every(function(item) { return item === null })) {
      newQueue = []
    }
    popupQueue = newQueue
    hidden = hidden.concat([n])
    delete _showTimes[n.id]
    delete _pausedAt[n.id]
    console.log("[Queue] Hidden notif", n.id, "queue:", popupQueue.map(function(i) { return i ? i.id : "null" }))
  }

  // Clean up queue by id when notification object is already gone (e.g. server closed it via invoke())
  function hideById(id) {
    _pendingDismiss = _pendingDismiss.filter(function(pid) { return pid !== id })
    var newQueue = popupQueue.map(function(item) {
      // Remove nulls, destroyed QObjects (truthy but id is undefined), and items matching the id
      if (!item || item.id === undefined || item.id === id) return null
      return item
    })
    if (newQueue.every(function(item) { return item === null })) {
      newQueue = []
    }
    popupQueue = newQueue
    delete _showTimes[id]
    delete _pausedAt[id]
    console.log("[Queue] HideById notif", id, "queue:", popupQueue.map(function(i) { return i ? i.id : "null" }))
  }

  function clearHidden() { hidden = []; }

  // Dismiss a saved notification from the center
  function dismissSaved(savedId) {
    savedNotifications = savedNotifications.filter(function(s) { return s._savedId !== savedId })
  }

  function pauseDismiss(n) {
    if (n && n.id) {
      _pausedAt[n.id] = Date.now()
      console.log("[Timer] Paused dismiss for notif", n.id)
    }
  }

  function resumeDismiss(n) {
    if (n && n.id && _pausedAt[n.id]) {
      // Extend show time by the pause duration so remaining countdown is preserved
      var pauseDuration = Date.now() - _pausedAt[n.id]
      if (_showTimes[n.id]) _showTimes[n.id] += pauseDuration
      delete _pausedAt[n.id]
      console.log("[Timer] Resumed dismiss for notif", n.id, "extended by", pauseDuration, "ms")
    }
  }

  function enqueue(n) {
    // Compact: remove nulls AND pending-dismiss notifications (treat them as already gone)
    var active = []
    var completed = []
    for (var i = 0; i < popupQueue.length; i++) {
      var item = popupQueue[i]
      if (item === null) continue
      if (_pendingDismiss.indexOf(item.id) >= 0) {
        completed.push(item)
        continue
      }
      active.push(item)
    }

    // Finish pending dismissals immediately (move to hidden, clean up tracking)
    for (var j = 0; j < completed.length; j++) {
      hidden = hidden.concat([completed[j]])
      delete _showTimes[completed[j].id]
      delete _pausedAt[completed[j].id]
      console.log("[Queue] Force-completed pending dismiss for notif", completed[j].id)
    }
    if (completed.length > 0) {
      _pendingDismiss = _pendingDismiss.filter(function(id) {
        for (var k = 0; k < completed.length; k++) {
          if (completed[k].id === id) return false
        }
        return true
      })
    }

    // Add newest to front
    var newQueue = [n].concat(active)

    // Animated eviction: mark overflow for dismiss, keep in queue for exit animation
    if (newQueue.length > maxVisible) {
      var overflow = newQueue[maxVisible]
      if (overflow && _pendingDismiss.indexOf(overflow.id) < 0) {
        console.log("[Queue] Evicting oldest notif", overflow.id, "(animated)")
        requestDismiss(overflow)
      }
    }
    // Hard limit: immediately evict anything beyond maxVisible+1
    while (newQueue.length > maxVisible + 1) {
      var evicted = newQueue.pop()
      if (evicted) {
        console.log("[Queue] Hard-evicting notif", evicted.id)
        hidden = hidden.concat([evicted])
        delete _showTimes[evicted.id]
        delete _pausedAt[evicted.id]
      }
    }

    // Record show time for new notification (only once)
    if (!_showTimes[n.id]) {
      _showTimes[n.id] = Date.now()
    }

    _lastEnqueuedId = n.id
    popupQueue = newQueue
    console.log("[Queue] Enqueued notif", n.id, "queue:", newQueue.map(function(i) { return i ? i.id : "null" }))
  }

  // queue[0] = newest (top popup), queue[length-1] = oldest (bottom popup)
  function popupAt(i) {
    return (i < popupQueue.length) ? popupQueue[i] : null
  }

  property int _nextSavedId: 0

  Process {
    id: soundPlayer
    command: ["pw-play", "/home/dinozover/.config/quickshell/sounds/notification-sound"]
    running: false
  }

  Timer {
    id: soundResetTimer
    interval: 50
    onTriggered: soundPlayer.running = true
  }

  NotificationServer {
    id: srv
    keepOnReload: false
    actionsSupported: true
    actionIconsSupported: true
    onNotification: (n) => {
      console.log("[notify-send]", n.appName, "-", n.summary)
      n.tracked = true

      // Save notification data as a plain object so it persists after app closes it
      var savedId = api._nextSavedId++
      var saved = {
        _savedId: savedId,
        appName: n.appName || "",
        summary: n.summary || "",
        body: n.body || "",
        image: n.image || "",
        appIcon: n.appIcon || "",
        actions: []
      }
      api.savedNotifications = [saved].concat(api.savedNotifications)

      if (!api.dnd) {
        soundPlayer.running = false
        soundResetTimer.restart()
        Qt.callLater(() => { api.enqueue(n) })
      }
    }
  }

  readonly property var model: srv.trackedNotifications
  readonly property int count: savedNotifications.length
  function clearAll() {
    popupQueue = []
    _showTimes = {}
    _pausedAt = {}
    savedNotifications = []
    // Also clear any live tracked notifications
    var vals = model ? model.values : []
    for (let i = vals.length; i > 0; i--) {
      vals[0].tracked = false
    }
  }
}
