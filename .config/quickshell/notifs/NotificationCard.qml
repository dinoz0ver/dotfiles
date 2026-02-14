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
  property int radius: 4

  width: parent ? parent.width : 0
  height: card.implicitHeight

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
          implicitWidth: 40; implicitHeight: 40
          radius: 20
          visible: image.visible
          IconImage {
            id: image
            anchors.fill: parent
            mipmap: true
            source: (root.n.image && root.n.image !== "") ? root.n.image : (root.n.appIcon && root.n.appIcon !== "") ? Quickshell.iconPath(root.n.appIcon) : ""
            visible: source !== ""
          }
        }
        Column {
          id: text
          width: root.width-icon.implicitWidth-12
          spacing: 2
          Text {
            text: root.n.appName+" - "+root.n.summary
            color: root.popup ? root.bg : root.fg
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            font.bold: true
          }
          Text {
            text: root.n.body
            color: root.popup ? root.bg : root.fg
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
          }
        }
      }
      Flow {
        id: actionBar
        spacing: 2
        visible: root.n.actions && root.n.actions.length > 0
        Repeater {
          model: root.n.actions
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
               color: root.popup ? root.bg : root.fg
            }
            MouseArea{ anchors.fill: parent; onClicked: modelData.invoke() }
          }
        }
      }
    }

    Rectangle {
      id: dismiss
      width: 18
      height: 18
      radius: 10
      color: root.bg
      anchors {
        right: parent.right; top: parent.top
        rightMargin: 6; topMargin: 6
      }
      Text { 
        anchors {
          right: parent.right; top: parent.top
          rightMargin: 3.5; topMargin: -3
        }
        text: ""
        font.pixelSize: 16
        color: root.fg
      }
      MouseArea {anchors.fill: parent; onClicked: root.popup ? Notifications.hide(root.n) : root.n.dismiss() }
    }

    Timer {
      id: __autoDismissTimer
      interval: Notifications.autoCloseMs
      repeat: false
      onTriggered: {
        if (root.n) Notifications.hide(root.n);
      }
    }
    
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.popup
      acceptedButtons: Qt.NoButton
      onEntered: { __autoDismissTimer.stop() }
      onExited: { __autoDismissTimer.restart() }
      Component.onCompleted: { __autoDismissTimer.start() }
    }   
  }
}