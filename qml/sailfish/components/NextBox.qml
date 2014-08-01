import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: nextBox

    signal areaClicked()

    property string text: ""
    property bool highlight: false

    width: parent.width
    height: nextImage.height
    //color: mouseArea.pressed || highlight ? mytheme.colors.backgroundSand : mytheme.colors.backgroundMain

    Text {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        width: parent.width
        font.pixelSize: myTheme.fontSizeMedium
        color: myTheme.primaryColor

        text: nextBox.text
    }
    Image {
        id: nextImage
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        source: "image://theme/icon-m-right"
        asynchronous: true
    }
    onClicked: {
        nextBox.areaClicked();
    }
/*    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            nextBox.areaClicked();
        }
    }
*/
}
