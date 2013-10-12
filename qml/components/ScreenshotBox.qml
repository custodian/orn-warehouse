import Qt 4.7

Item {
    id: screenshotBox

    property variant screenshots: []
    property int __selected: 0
    width: parent.width
    height: Math.max(fullview.height, thumbs.height)

    MouseArea {
        anchors.fill: parent
    }

    CacheImage {
        id: fullview
        width: 360
        height: 640
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 20
        }
        fillMode: Image.PreserveAspectCrop
        //sourceUncached: undefined
    }

    Column {
        id: thumbs
        spacing: 10
        anchors {
            top: parent.top
            topMargin: 10
            right: parent.right
            rightMargin: 20
        }
        Repeater {
            model: screenshotBox.screenshots
            delegate: Rectangle {
                width: 56
                height: 100
                border.width: 4
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
