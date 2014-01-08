import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components-jolla"

import "../js/api.js" as Api

PageWrapper {
    id: appDetails
    signal update()
    signal comments(variant app)
    signal browse(string userid, string username)

    property variant application: {}

    signal appFullLoaded()

    width: parent.width
    height: parent.height

    headerText: qsTr("Application details")

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
        appFullLoaded();
    }

    content: SilicaFlickable{
        id: flickableArea
        contentWidth: width

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
                categoryStyle: "full"
            }

            AppManageBox {
                id: manageBox

                Connections {
                    target: appDetails
                    onAppFullLoaded: {
                        if (appDetails.application.packages.sailfish !== undefined) {
                            manageBox.repositoryName = appDetails.application.user.name;
                            manageBox.appPackage = appDetails.application.packages.sailfish;
                        }
                    }
                }
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
                color: myTheme.primaryColor

                font.pixelSize: myTheme.fontSizeSmall
                horizontalAlignment: Text.AlignHCente
                wrapMode: Text.WordWrap

                text: application.body !== undefined ? application.body + "<br>" : ""
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
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
            }
        }
    }
}
