import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/api.js" as Api

BackgroundItem {
    id: appItem

    property variant application: {}
    property bool highlight: false
    property string categoryStyle: "small" //full

    width: parent.width
    height: Math.max(statusArea.height, appImage.height) + 2 * myTheme.paddingMedium

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
            verticalCenter: parent.verticalCenter
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
            verticalCenter: parent.verticalCenter
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
            text: Api.categories.parse(application.category, appItem.categoryStyle)
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
}
