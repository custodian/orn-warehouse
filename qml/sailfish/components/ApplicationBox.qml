import QtQuick 2.0

Item {
//Rectangle {
    id: appItem

    signal areaClicked()
    signal areaPressAndHold()

    property variant application: {}
    property bool highlight: false
    property string categoryStyle: "small" //full

    width: parent ? parent.width : undefined
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
            leftMargin: myTheme.paddingLarge
            top: parent.top
            topMargin: myTheme.paddingLarge
        }
        masked: false//true
    }

    Column {
        id: statusArea
        spacing: myTheme.paddingSmall
        anchors {
            left: appImage.right
            leftMargin: myTheme.paddingLarge
            right: parent.right
            rightMargin: myTheme.paddingLarge
            top: parent.top
            topMargin: myTheme.paddingSmall
        }

        Text {
            id: appNameText
            //color: myTheme.primaryColor
            color: myTheme.highlightColor
            font.pixelSize: myTheme.fontSizeMedium
            font.bold: true
            width: parent.width
            text: application.title
            wrapMode: Text.Wrap
            visible: appNameText.text != ""
        }

        Text {
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            width: parent.width
            text: categotyParser.parse(application.category, appItem.categoryStyle)
            wrapMode: Text.Wrap
        }

        RatingBox {
            rating: application.rating
            width: parent.width

            Text {
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeExtraSmall
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                text: application.user ? qsTr("by %1").arg(application.user.name) : ""
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
