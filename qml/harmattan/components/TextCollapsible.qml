import QtQuick 1.1
import "."

Text {
    id: root

    clip: true

    property int maxHeight: 200

    property int __fullHeight: 0
    property bool __overflow: false
    property bool __collapsed: false

    onLinkActivated: {
        appWindow.openLink(link);
    }
    function updateHeight() {
        if (__overflow) {
            if (__collapsed) {
                root.height = maxHeight;
            } else {
                root.height = __fullHeight;
            }
        }
    }

    onTextChanged: {
        if (root.height > maxHeight) {
            __overflow = true;
            __collapsed = true;
            __fullHeight = root.height;
            updateHeight();
        }
    }

    Rectangle {
        width: parent.width
        height: 75
        anchors {
            bottom: root.bottom
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: mytheme.colors.backgroundMain }
        }
        Image {
            id: imageArrowz
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            source: __collapsed?"image://theme/icon-m-toolbar-down":"image://theme/icon-m-toolbar-up"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                __collapsed = !__collapsed;
                updateHeight();
            }
        }
        visible: __overflow
    }

}
