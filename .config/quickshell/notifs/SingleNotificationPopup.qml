// SingleNotificationPopup.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import ".." as Root

PopupWindow {
  id: root

  property color bg: "#ffffff"
  property color fg: "#000000"
  property color color1: "#ff0000"
  property color color2: "#00ff00"
  property color color4: "#f0f000"
  property var notification: null
  property int popupIndex: 0
  property int maxPopups: 3
  property int verticalOffset: 0
  property int previousSlotOffset: 0  // vertical offset of the popup slot above (where shifted content came from)
  property bool dismissing: false
  property int _dismissingId: -1  // track which notif we're dismissing (needed if object gets destroyed mid-dismiss)
  property bool _resetting: false  // bypass Behavior on x/opacity when resetting card position
  property int cardWidth: 300

  // Unmap when inactive so compositor discards old buffer (prevents ghost artifacts)
  visible: _active
  color: "transparent"

  onNotificationChanged: {
    console.log("[Popup" + popupIndex + "] notification changed to:", notification ? notification.id : "null", "was dismissing:", dismissing)
    if (enterAnim.running) enterAnim.stop()

    if (notification && notification.id !== undefined) {
      if (dismissAnim.running) dismissAnim.stop()
      var isNewArrival = notification.id === Notifications._lastEnqueuedId
      dismissing = false
      if (isNewArrival) {
        // New notification -> slide in from right
        enterAnim.start()
      } else {
        // Shifted down in stack -> slide from previous slot position to current
        _resetting = true; card.x = 0; _resetting = false
        restackAnim.stop()
        _smoothOffset = previousSlotOffset
        restackAnim.from = previousSlotOffset
        restackAnim.to = verticalOffset
        restackAnim.start()
      }
    } else if (dismissing) {
      // Notification destroyed mid-dismiss (e.g. action invoke closed it)
      // End immediately - card is already invisible, no point animating
      if (dismissAnim.running) dismissAnim.stop()
      var savedId = _dismissingId
      _resetting = true; card.x = 0; _resetting = false
      dismissing = false
      _dismissingId = -1
      // Defer hideById to break the synchronous chain:
      // notification binding -> onNotificationChanged -> hideById -> popupQueue change -> notification binding
      // Without deferral this is a binding loop that can crash the compositor
      if (savedId >= 0) Qt.callLater(function() { Notifications.hideById(savedId) })
    } else {
      // Notification removed without dismiss animation (force-complete) - clean up
      _resetting = true; card.x = 0; _resetting = false
    }
  }

  // Detect timer/X-button dismiss request from Notifications singleton
  property bool _dismissRequested: {
    if (!notification) return false
    var pending = Notifications._pendingDismiss
    for (var i = 0; i < pending.length; i++) {
      if (pending[i] === notification.id) return true
    }
    return false
  }

  on_DismissRequestedChanged: {
    if (_dismissRequested && !dismissing) {
      console.log("[Popup" + popupIndex + "] Animated dismiss for notif", notification ? notification.id : "null")
      dismissing = true
      _dismissingId = notification ? notification.id : -1
      dismissAnim.from = card.x
      dismissAnim.to = card.width
      dismissAnim.start()
    }
  }

  // Dead QObjects are truthy and !== null but have id === undefined; exclude them
  property bool _active: (notification !== null && notification.id !== undefined) || dismissing
  // Double width so card can slide left without being cropped by window surface
  implicitWidth: cardWidth * 2
  implicitHeight: Math.max(1, card.implicitHeight)

  // Smooth vertical repositioning when popups restack
  property real _smoothOffset: 0

  NumberAnimation {
    id: restackAnim
    target: root
    property: "_smoothOffset"
    duration: 250
    easing.type: Easing.OutCubic
  }

  Component.onCompleted: _smoothOffset = verticalOffset
  onVerticalOffsetChanged: {
    restackAnim.stop()
    restackAnim.from = _smoothOffset
    restackAnim.to = verticalOffset
    restackAnim.start()
  }

  anchor.rect.x: parentWindow.width - implicitWidth
  anchor.rect.y: parentWindow.height
  anchor.margins.top: 6 + _smoothOffset

  // New notification: slide in from right
  NumberAnimation {
    id: enterAnim
    target: card
    property: "x"
    from: root.cardWidth
    to: 0
    duration: 250
    easing.type: Easing.OutCubic
  }

  // Dismiss: slide out and then hide
  NumberAnimation {
    id: dismissAnim
    target: card
    property: "x"
    duration: 250
    easing.type: Easing.InOutQuad
    onFinished: {
      console.log("[Popup" + root.popupIndex + "] Dismiss anim finished, hiding notif", root.notification ? root.notification.id : root._dismissingId)
      var n = root.notification
      var savedId = root._dismissingId
      // Clear dismissing state BEFORE hide() so that the onNotificationChanged
      // handler (triggered by popupQueue change) won't re-enter the dismissing
      // branch and call hideById redundantly (which causes a binding loop + crash)
      root.dismissing = false
      root._dismissingId = -1
      if (n) {
        Notifications.hide(n)
      } else if (savedId >= 0) {
        // Notification object already destroyed (e.g. action invoke closed it) - clean up by id
        Notifications.hideById(savedId)
      }
    }
  }

  NotificationCard {
    id: card
    visible: root.notification !== null && root.notification.id !== undefined
    n: root.notification
    popup: true
    bg: root.bg
    fg: root.fg
    color1: root.color1
    color2: root.color2
    color4: root.color4
    width: root.cardWidth

    // Shift card to right side of the wider window so leftward swipes stay within bounds
    transform: Translate { x: root.cardWidth }

    // Opacity tied to card position for enter/drag/dismiss
    opacity: {
      if (enterAnim.running) {
        return Math.max(0, 1 - card.x / root.cardWidth)
      }
      if (root.dismissing) return 0
      return Math.max(0.3, 1 - Math.abs(x) / 200)
    }

    // Swipe snap-back only (dismiss uses standalone dismissAnim)
    Behavior on x {
      enabled: !dragArea.drag.active && !enterAnim.running && !dismissAnim.running && !root._resetting
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutBack
      }
    }

    Behavior on opacity {
      enabled: !enterAnim.running && !root._resetting
      NumberAnimation {
        duration: root.dismissing ? 250 : 150
        easing.type: Easing.OutCubic
      }
    }

    MouseArea {
      id: dragArea
      anchors.fill: parent
      drag.target: card
      drag.axis: Drag.XAxis
      drag.minimumX: -card.width
      drag.maximumX: card.width

      onPressed: (mouse) => {
        // Don't intercept clicks on the dismiss button (top-right corner)
        const dismissButtonArea = 30
        if (mouse.x > card.width - dismissButtonArea && mouse.y < dismissButtonArea) {
          mouse.accepted = false
          return
        }
        // Don't intercept clicks on action buttons
        if (card.hasActions && mouse.y >= card.actionBarTop) {
          mouse.accepted = false
          return
        }
      }

      onReleased: {
        const threshold = 100
        const dragDistance = Math.abs(card.x)

        console.log("[Swipe] popup" + root.popupIndex, "dragDistance:", dragDistance, "threshold:", threshold, "card.x:", card.x)

        if (dragDistance > threshold) {
          console.log("[Swipe] Dismissing popup" + root.popupIndex, "notif:", root.notification ? root.notification.id : "null")
          root.dismissing = true
          root._dismissingId = root.notification ? root.notification.id : -1
          if (root.notification) Notifications.requestDismiss(root.notification)
          dismissAnim.from = card.x
          dismissAnim.to = (card.x > 0) ? card.width : -card.width
          dismissAnim.start()
        } else {
          console.log("[Swipe] Snapping back popup" + root.popupIndex)
          card.x = 0
        }
      }
    }
  }
}
