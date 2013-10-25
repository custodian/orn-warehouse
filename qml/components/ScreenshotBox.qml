import Qt 4.7

Item {
    id: screenshotBox

    property variant screenshots: []
    property int __selected: 0
    width: parent.width
    height: Math.max(fullview.height, flickableArea.height)

    MouseArea {
        anchors.fill: parent
    }

    CacheImage {
        id: fullview
        width: 360
        height: 640
        smooth: true
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 20
        }
        fillMode: Image.PreserveAspectCrop
    }

    Flickable{
        id: flickableArea
        anchors {
            top: parent.top
            topMargin: 10
            right: parent.right
            rightMargin: 20
        }
        width: 68
        height: fullview.height
        contentWidth: width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 6
            }
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + anchors.margins*2;
            }

            Repeater {
                model: screenshotBox.screenshots
                delegate: Rectangle {
                    width: 56
                    height: 100
                    border.width: 6
                    border.color: __selected == index ? "blue" : "gray"
                    color: "transparent"
                        CacheImage {
                            id: thumb
                            anchors {
                                top: parent.top
                                right: parent.right
                            }
                            width: 56
                            height: 100
                            sourceUncached: modelData.thumbs.small

                            Component.onCompleted: {
                                if (index === 0) {
                                    fullview.sourceUncached = modelData.thumbs.large;
                                }
                            }
                        }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            __selected = index;
                            fullview.sourceUncached = modelData.thumbs.large;
                        }
                    }
                }
            }
        }
    }
}
