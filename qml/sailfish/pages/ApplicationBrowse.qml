import QtQuick 2.0
import Sailfish.Silica 1.0
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

    headerText: qsTr("Browse applications")

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

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

    ListModel {
        id: appsModel
    }

    content: SilicaFlickable {
        id: appsFlickable
        clip: true
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            Label {
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                text: qsTr("Page #%1").arg(appList.page)
            }

            Repeater {
                model: appsModel
                delegate: appDelegate
            }

            Item {
                width: parent.width
                height: pagerRow.height + 30

                Row {
                    id: pagerRow
                    anchors.centerIn: parent
                    spacing: 4
                    Button {
                        //anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Prev page")
                        visible: appList.page > 0
                        onClicked: {
                            appList.page--;
                            appList.update();
                            appsFlickable.contentY = 0
                        }
                    }
                    Button {
                        //anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Next page")
                        visible: appsModel.count == appList.pageSize && options.type != "user" //FIX: remove when api will be changed
                        onClicked: {
                            appList.page++;
                            appList.update();
                            appsFlickable.contentY = 0
                        }
                    }
                }
            }
        }
        //ScrollDecorator{ flickable: appsFlickable }
        VerticalScrollDecorator {}
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
