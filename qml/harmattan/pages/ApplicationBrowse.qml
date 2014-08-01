import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appList
    signal update()
    signal application(variant app)

    property variant options: {}
    property int page: 0
    property int pageSize: 20
    property alias appsModel: appsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Browse applications")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        page.update.connect(function(){
            Api.apps.browseApps(page);
        });
        page.application.connect(function(app) {
            stack.push(Qt.resolvedUrl("Application.qml"),{"application":app});
        });
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: appsModel
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
            height: headerColumn.height + 10
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
                    topMargin: 5
                }
                Text {
                    id: textHeader
                    color: mytheme.colors.textColorSign
                    anchors {
                        left: parent.left
                        leftMargin: 10
                    }
                    text: qsTr("Page %1").arg(appList.page)
                    font.pixelSize: mytheme.font.sizeSigns
                }
            }
        }

        footer: Item {
            width: parent.width
            height: pagerRow.height + 30

            ButtonRow {
                id: pagerRow
                anchors.centerIn: parent
                exclusive: false
                Button {
                    //anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Prev page")
                    visible: appList.page > 0
                    onClicked: {
                        appList.page--;
                        update();
                    }
                }
                Button {
                    //anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Next page")
                    visible: appsModel.count == appList.pageSize && options.type != "user" //FIX: remove when api will be changed
                    onClicked: {
                        appList.page++;
                        update();
                    }
                }
            }
        }
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
