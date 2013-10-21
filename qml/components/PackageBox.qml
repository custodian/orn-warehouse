import Qt 4.7
import "."

Rectangle {
    id: appItem

    signal areaClicked()
    signal areaPressAndHold()

    property variant application: model.application
    property bool highlight: false
    property bool onlyName: false

    color: mouseArea.pressed || highlight ? mytheme.colors.backgroundSand : mytheme.colors.backgroundMain
    width: parent.width
    height: 10 + Math.max(statusArea.height,appImage.height)

    onApplicationChanged: {
        var url = "../images/default_package.png"
        if (application.IconData !== undefined) {
            if (application.IconData.length > 10) {
                url = "base64://" + application.IconData + ".png";
            }
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
            color: mytheme.colors.textColorOptions
            font.pixelSize: onlyName ? mytheme.font.sizeSettigs : mytheme.font.sizeSigns
            font.bold: true
            width: parent.width
            text: application.DisplayName.length > 0 ? application.DisplayName : application.Name
            wrapMode: Text.Wrap
            visible: appNameText.text != ""
        }

        Text {
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeHelp
            width: parent.width
            text: application.Category
            wrapMode: Text.Wrap

            Text {
                color: mytheme.colors.textColorShout
                font.pixelSize: mytheme.font.sizeNote
                anchors {
                    right: parent.right
                    rightMargin: 12
                    bottom: parent.bottom
                }
                text: qsTr("Version %1").arg(application.Version)
            }
            visible: !onlyName
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
