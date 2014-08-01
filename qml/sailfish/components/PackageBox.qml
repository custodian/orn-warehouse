import QtQuick 2.0
import "."

Item {
    id: appItem

    signal areaClicked()
    signal areaPressAndHold()

    property variant application

    width: parent.width
    height: 10 + Math.max(statusArea.height,appImage.height)

    onApplicationChanged: {
        var url = "../images/default_package.png"
        if (application.icon) {
            //TODO: only icon name here, need to get full link to local system
            url = "/usr/share/icons/hicolor/86x86/apps/%1.png".arg(application.icon);
        }
        appImage.photoUrl = url;
    }

    MaskedImage {
        id: appImage
        anchors {
            left: parent.left
            leftMargin: 12
            top: parent.top
            topMargin: 4
        }
        masked: false//true
    }

    Column {
        id: statusArea
        spacing: 4
        anchors {
            left: appImage.right
            leftMargin: 12
            right: parent.right
            rightMargin: 12
            top: parent.top
            topMargin: 4
        }

        Text {
            id: appNameText
            color: myTheme.highlightColor
            font.pixelSize: myTheme.fontSizeMedium
            font.bold: true
            width: parent.width
            text: application.name
            wrapMode: Text.Wrap
        }

        Text {
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            width: parent.width
            text: application.data?application.data:""
            wrapMode: Text.Wrap

            Text {
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                anchors {
                    right: parent.right
                    rightMargin: 12
                    bottom: parent.bottom
                }
                text: qsTr("Version %1").arg(application.version)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            appItem.areaClicked();
        }
        onPressAndHold: {
            appItem.areaPressAndHold();
        }
    }
}
