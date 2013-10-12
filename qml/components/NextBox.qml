import Qt 4.7

Rectangle {
    id: nextBox

    signal areaClicked()

    property string text: ""
    property bool highlight: false

    width: parent.width
    height: nextImage.height*2
    color: mouseArea.pressed || highlight ? mytheme.colors.backgroundSand : mytheme.colors.backgroundMain

    Text {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        width: parent.width
        font.pixelSize: mytheme.font.sizeSigns

        text: nextBox.text
    }
    Image {
        id: nextImage
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        source: "image://theme/icon-s-common-next"
        asynchronous: true
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            nextBox.areaClicked();
        }
    }
}
