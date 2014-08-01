import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appDetails
    signal update()
    signal comments(variant app)
    signal browse(string userid, string username)

    property variant application: {}

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Application details")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appDetails;
        page.update.connect(function(){
            Api.apps.loadApplication(page, application.appid);
        })
        page.browse.connect(function(userid, username){
            stack.push(Qt.resolvedUrl("ApplicationBrowse.qml"),
               {
                    "options": {"type": "user", "id": userid},
                    "headerText": qsTr("Apps by: %1").arg(username),
               });
        });
        page.comments.connect(function(app) {
            stack.push(Qt.resolvedUrl("CommentsRate.qml"), {"application": app});
        });
        page.update();
    }

    function appLoaded() {
        if (application.packages.harmattan !== undefined) {
            manageBox.repositoryName = application.user.name;
            manageBox.apppackage = application.packages.harmattan;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            width: parent.width
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            ApplicationBox {
                application: appDetails.application
                categorystyle: "full"
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: mytheme.paddingLarge * 2
                Row {
                    spacing: mytheme.paddingMedium
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-s-common-like"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        //color: mytheme.primaryColor
                        font.pixelSize: mytheme.font.sizeHelp
                        text: appDetails.application.rating.count
                    }
                }
                Row {
                    spacing: mytheme.paddingMedium
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-s-transfer-download"
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        //color: myTheme.primaryColor
                        font.pixelSize: mytheme.font.sizeHelp
                        text: appDetails.application.downloads ? appDetails.application.downloads : ""
                    }
                }
            }

            AppManageBox {
                id: manageBox
            }

            SectionHeader {
                text: qsTr("Description")
            }
            TextCollapsible {
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }

                font.pixelSize: mytheme.font.sizeHelp
                wrapMode: Text.WordWrap

                text: application.body !== undefined ? application.body + "<br>" : ""
            }

            SectionHeader {
                text: qsTr("Changelog")
                visible: textChangelog.text.length
            }
            TextCollapsible {
                id: textChangelog
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }

                font.pixelSize: mytheme.font.sizeHelp
                wrapMode: Text.WordWrap

                text: application.changelog !== undefined ? application.changelog+ "\n": ""
                visible: text.length
            }

            SectionHeader {
                text: qsTr("Comments & reviews")
            }
            NextBox {
                text: qsTr("Comments (%1)").arg(application.comments_count);

                RatingBox {
                    anchors {
                        right: parent.right
                        rightMargin: 100
                        verticalCenter: parent.verticalCenter
                    }
                    rating: application.rating
                }
                onAreaClicked: {
                    appDetails.comments(application);
                }
            }

            SectionHeader {
                text: qsTr("Screenshots")
                visible: application.screenshots!== undefined
            }
            ScreenshotBox {
                screenshots: application.screenshots
                visible: application.screenshots!== undefined
            }

            SectionHeader {
                text: qsTr("Publisher")
            }
            NextBox {
                text: qsTr("More apps by %1").arg(application.user.name);
                onAreaClicked: {
                    appDetails.browse(application.user.uid, application.user.name);
                }
            }

            SectionHeader {
                text: qsTr("Releated")
            }
            Text {
                text: "some related stuff by cat and tags"
                font.pixelSize: mytheme.font.sizeHelp
            }
        }
    }

    Component {
        id: catDelegate

        Item{

        }
    }
}
