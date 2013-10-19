import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: commentPage
    signal update()

    property variant application
    property alias commentsModel: commentsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Comments and Reviews")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = commentPage;
        page.update.connect(function(){
            Api.apps.loadComments(page, application.appid);
        })
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: commentsModel
    }

    ListView {
        model: commentsModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
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
                    color: mytheme.colors.textColorSign
                    anchors {
                        left: parent.left
                        leftMargin: 10
                    }
                    text: qsTr("Raiting options")
                    font.pixelSize: mytheme.font.sizeSigns
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
                spacing: 10

                Text {
                    id: username
                    color: mytheme.colors.textColorOptions
                    font.pixelSize: mytheme.font.sizeSigns
                    font.bold: true
                    width: parent.width
                    text: model.user.name + " @ " + model.created
                    wrapMode: Text.Wrap
                }

                Text {
                    color: mytheme.colors.textColorShout
                    font.pixelSize: mytheme.font.sizeHelp
                    width: parent.width
                    text: model.text
                    wrapMode: Text.Wrap
                }
            }
        }



    }
}
