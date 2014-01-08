import QtQuick 2.0
import "../components-jolla"

import "../js/api.js" as Api

PageWrapper {
    id: commentPage
    signal update()

    property variant application
    property alias commentsModel: commentsModel

    width: parent.width
    height: parent.height

    headerText: qsTr("Comments and Reviews")

    function load() {
        var page = commentPage;
        page.update.connect(function(){
            Api.apps.loadComments(page, application.appid);
        })
        page.update();
    }

    ListModel {
        id: commentsModel
    }

    content: ListView {
        model: commentsModel
        delegate: commentDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400

        header: Item {
            height: headerColumn.height + 10
            width: parent.width
            Column {
                id: headerColumn
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: 5
                }
                ApplicationBox {
                    id: appbox
                    application: commentPage.application
                }
                SectionHeader {
                    text: qsTr("Rating");
                }
                Text {
                    id: textHeader
                    width: parent.width
                    color: myTheme.primaryColor
                    anchors {
                        left: parent.left
                        leftMargin: 10
                    }
                    text: qsTr("Rate application")
                    font.pixelSize: myTheme.fontSizeSmall
                }
                SectionHeader {
                    text: qsTr("Comments");
                }
            }
        }
    }

    Component {
        id: commentDelegate

        Item {
            width: parent.width
            height: Math.max(userPhoto.height, commentColumn.height) + 10

            MaskedImage {
                id: userPhoto
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                }
                photoSize: 64
                masked: true
                photoUrl: model.user.picture!== undefined ? model.user.picture.url : "../images/default_userpic.png"
            }

            Column {
                id: commentColumn
                anchors {
                    top: parent.top
                    left: userPhoto.right
                    right: parent.right
                    margins: 10
                }
                Text {
                    id: username
                    color: myTheme.primaryColor
                    font.pixelSize: myTheme.fontSizeMedium
                    font.bold: true
                    width: parent.width
                    text: model.user.name + " @ " + model.created
                    wrapMode: Text.Wrap
                }

                Text {
                    color: myTheme.primaryColor
                    font.pixelSize: myTheme.fontsizeSmall
                    width: parent.width
                    text: model.text
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
