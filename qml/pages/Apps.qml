import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appList
    signal application(variant app)
    signal update()

    property alias appsModel: appsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Applications")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        page.application.connect(function(app) {
            stack.push(Qt.resolvedUrl("Application.qml"),{"application":app});
        });
        page.update.connect(function(){
            Api.apps.loadRecent(page);
        })
        page.update();
    }

    ListModel {
        id: appsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        model: appsModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: appDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400

        header: Item {
            height: headerColumn.height + 15
            width: parent.width
            Rectangle {
                anchors.fill: parent
                color: mytheme.colors.backgroundSplash
            }
            Column {
                id: headerColumn
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: 10
                }
                spacing: 4
                Image {
                    id: imageLogo
                    anchors.horizontalCenter: parent.horizontalCenter;
                    source: "../images/openrepos_beta.png"
                }
                Text {
                    id: textRecent
                    color: mytheme.colors.textColorSign
                    anchors {
                        left: parent.left
                        leftMargin: 10
                    }
                    text: qsTr("Recently updated apps");
                    font.pixelSize: mytheme.font.sizeHelp
                }
            }
        }

        /*footer: Column{
            width: parent.width
            ToolButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Load More")
                visible: !completed
                onClicked: {
                    completed = true;
                    update();
                }
            }
            Item {
                width: parent.width
                height: 20
            }
        }*/
    }

    Component {
        id: appDelegate

        ApplicationBox {
            id: appbox
            application: model.application

            onAreaClicked: {
                appList.application( model.application );
            }
        }
    }
}
