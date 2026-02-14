// AudioWidget.qml
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int heightBox: 34
    property int radius: 5
    property color bg: "#000000"
    property color fg: "#ffffff"
    property color color1: "#ff0000"
    property color color2: "#ffff00"

    implicitHeight: box.implicitHeight
    implicitWidth: parent.implicitWidth-12

    Rectangle {
        id: box
        implicitWidth: root.implicitWidth
        implicitHeight: column.implicitHeight
        radius: root.radius
        color: root.bg
        border.width: 2; border.color: root.color1
        Column {
            id: column
            padding: 6
            spacing: 6

            Row {
                spacing: 6

                Text {
                    padding: 3
                    text: "Output: "
                    font.pixelSize: 14
                    color: root.fg
                }

                Rectangle {
                    width: 25
                    height: 25
                    radius: root.radius
                    color: root.color2
                    Text {
                        topPadding: 4
                        leftPadding: 5
                        text: Audio.sink.audio.muted ? "" : ""
                        font.pixelSize: 14
                        color: root.fg
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Audio.toggleMute(true)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Row {
                    padding: 4
                    spacing: 6
                    Slider {
                        id: slider
                        from: 0; to: 100
                        value: Math.round(Audio.sink.audio.volume*100)
                        onMoved: Audio.setVolume(value, true)
                        background: Rectangle {
                            x: slider.leftPadding
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 250
                            implicitHeight: 8
                            width: slider.availableWidth
                            height: implicitHeight
                            radius: 4
                            color: root.color1
                            border.color: root.color1
                            border.width: 2

                            Rectangle {
                                width: slider.visualPosition * parent.width
                                height: parent.height
                                color: root.color2
                                radius: 4
                            }
                        }

                        handle: Rectangle {
                            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                            y: slider.topPadding + slider.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 13
                            color: slider.pressed ? root.fg : root.fg
                            border.color: slider.pressed ? root.fg : root.fg
                            border.width: 2
                        }
                    }

                    Text {
                        text: Math.round(slider.value) + "%"
                        color: root.fg
                        font.pixelSize: 14
                    }
                }
                //Text {
                //    text: Audio.sink.ready+" "+Audio.isReady
                //    color: "#ffffff"
                //}
            }
            Row {
                spacing: 6

                Text {
                    padding: 3
                    text: "Input:  "
                    font.pixelSize: 14
                    color: root.fg
                }

                Rectangle {
                    width: 25
                    height: 25
                    radius: root.radius
                    color: root.color2
                    Text {
                        topPadding: 4
                        leftPadding: 5
                        text: Audio.source.audio.muted ? "" : ""
                        font.pixelSize: 14
                        color: root.fg
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Audio.toggleMute(false)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Row {
                    padding: 4
                    spacing: 6
                    Slider {
                        id: sliderSource
                        from: 0; to: 100
                        value: Math.round(Audio.source.audio.volume*100)
                        onMoved: Audio.setVolume(value, false)
                        background: Rectangle {
                            x: sliderSource.leftPadding
                            y: sliderSource.topPadding + sliderSource.availableHeight / 2 - height / 2
                            implicitWidth: 250
                            implicitHeight: 8
                            width: sliderSource.availableWidth
                            height: implicitHeight
                            radius: 4
                            color: root.color1
                            border.color: root.color1
                            border.width: 2

                            Rectangle {
                                width: sliderSource.visualPosition * parent.width
                                height: parent.height
                                color: root.color2
                                radius: 4
                            }
                        }

                        handle: Rectangle {
                            x: sliderSource.leftPadding + sliderSource.visualPosition * (sliderSource.availableWidth - width)
                            y: sliderSource.topPadding + sliderSource.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: 13
                            color: sliderSource.pressed ? root.fg : root.fg
                            border.color: sliderSource.pressed ? root.fg : root.fg
                            border.width: 2
                        }
                    }

                    Text {
                        text: Math.round(sliderSource.value) + "%"
                        color: root.fg
                        font.pixelSize: 14
                    }
                }
                //Text {
                //    text: Audio.source.ready+" "+Audio.isReady
                //    color: "#ffffff"
                //}
            }
        }
    }
}