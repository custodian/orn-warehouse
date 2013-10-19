import Qt 4.7

//Item {
Rectangle {
    id: appItem

    signal areaClicked()
    signal areaPressAndHold()

    property variant application: {}
    property bool highlight: false
    property string categorystyle: "small" //full

    color: mouseArea.pressed || highlight ? mytheme.colors.backgroundSand : mytheme.colors.backgroundMain
    width: parent.width
    height: 10 + Math.max(statusArea.height,appImage.height)

    onApplicationChanged: {
        var url = "../images/default_package.png"
        if (application.icon !== undefined) {
            if (application.icon.url!==undefined) {
                url = application.icon.url;
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
            font.pixelSize: mytheme.font.sizeSigns
            font.bold: true
            width: parent.width
            text: application.title
            wrapMode: Text.Wrap
            visible: appNameText.text != ""
        }

        Text {
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeHelp
            width: parent.width
            text: categotyParser.parse(application.category, appItem.categorystyle)
            wrapMode: Text.Wrap

            Text {
                color: mytheme.colors.textColorShout
                font.pixelSize: mytheme.font.sizeNote
                anchors {
                    right: parent.right
                    rightMargin: 12
                    bottom: parent.bottom
                }
                text: application.user ? qsTr("by %1").arg(application.user.name) : ""
            }
        }

        RatingBox {
            rating: application.rating
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
