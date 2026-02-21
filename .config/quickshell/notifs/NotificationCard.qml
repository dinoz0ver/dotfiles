// NotificationCard.qml

import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
  id: root
  property var n
  property bool popup
  //property bool showTimestamp: !popup
  property bool autoDismiss: popup

  property color bg: "#ff0000"
  property color fg: "#ff00ff"
  property color color1: "#ffffff"
  property color color2: "#00ff00"
  property color color4: "#f0f000"
  property int radius: 4
  property bool hasActions: n && n.actions && n.actions.length > 0
  property real actionBarTop: hasActions ? actionBar.mapToItem(root, 0, 0).y : -1

  width: parent ? parent.width : 0
  implicitHeight: card.implicitHeight
  height: implicitHeight

  Rectangle {
    id: card
    anchors {
      fill: parent
    }
    radius: root.radius
    color: root.popup ? root.fg : root.bg
    implicitWidth: root.width
    implicitHeight: content.implicitHeight+6
    border.width: 2; border.color: root.popup ? root.fg : root.color1
    Column {
      id: content
      leftPadding: 6
      topPadding: 6
      spacing: 6
      Row {
        spacing: 6
        ClippingRectangle {
          id: icon
          width: 40; height: 40
          implicitWidth: 40; implicitHeight: 40
          radius: 20
          visible: root.n && ((root.n.image && root.n.image !== "") || (root.n.appIcon && root.n.appIcon !== ""))
          Image {
            id: image
            anchors.fill: parent
            mipmap: true
            fillMode: Image.PreserveAspectCrop
            source: root.n && root.n.image && root.n.image !== "" ? root.n.image : ""
            visible: source !== ""
          }
          IconImage {
            id: iconImage
            anchors.fill: parent
            mipmap: true
            source: root.n && root.n.appIcon && root.n.appIcon !== "" ? Quickshell.iconPath(root.n.appIcon) : ""
            visible: source !== "" && !image.visible
          }
        }
        Column {
          id: text
          width: root.width-icon.implicitWidth-12
          spacing: 2
          Text {
            text: root.n ? (root.n.appName+" - "+root.n.summary) : ""
            color: root.popup ? root.bg : root.fg
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            font.bold: true
          }
          Text {
            text: root.n ? root.n.body : ""
            color: root.popup ? root.bg : root.fg
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
          }
        }
      }
      Flow {
        id: actionBar
        spacing: 2
        visible: root.n && root.n.actions && root.n.actions.length > 0
        Repeater {
          model: root.n ? root.n.actions : []
          delegate: Rectangle {
            implicitWidth: actionText.implicitWidth+8
            implicitHeight: actionText.implicitHeight+8
            radius: 4
            color: root.bg
            Text {
               id: actionText;
               anchors {
                 top: parent.top; left: parent.left;
                 topMargin: 4; leftMargin: 4
               }
               text: modelData.text;
               color: root.popup ? root.fg : root.fg
            }
            MouseArea{ anchors.fill: parent; onClicked: {
              if (root.popup) {
                Notifications.requestDismiss(root.n)
              } else {
                Notifications.dismissSaved(root.n._savedId)
              }
              if (modelData.invoke) Qt.callLater(modelData.invoke)
            } }
          }
        }
      }
    }

    Rectangle {
      id: dismiss
      z: 1
      width: 18
      height: 18
      radius: 10
      color: "transparent"
      anchors {
        right: parent.right; top: parent.top
        rightMargin: 6; topMargin: 6
      }

      Behavior on color {
        ColorAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }

      Text {
        anchors {
          right: parent.right; top: parent.top
          rightMargin: 3.5; topMargin: -3
        }
        text: ""
        font.pixelSize: 16
        font.family: "Departure Mono"
        color: dismissHover.hovered ? root.color2 : (root.popup ? root.bg : root.fg)
      }
      HoverHandler {
        id: dismissHover
        cursorShape: Qt.PointingHandCursor
      }
      MouseArea {
        id: dismissMouse
        anchors.fill: parent
        onClicked: root.popup ? Notifications.requestDismiss(root.n) : Notifications.dismissSaved(root.n._savedId)
      }
    }

    HoverHandler {
      enabled: root.popup
      onHoveredChanged: {
        if (!root.n) return
        if (hovered) Notifications.pauseDismiss(root.n)
        else Notifications.resumeDismiss(root.n)
      }
    }
  }
}