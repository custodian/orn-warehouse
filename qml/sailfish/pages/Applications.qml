import "../js/api.js" as Api

//TODO: change to this
//import net.thecust.aui 1.0
//import "../components"

import QtQuick 2.0
import Sailfish.Silica 1.0

//import net.thecust.packagekit 1.0
import "../components"

PageWrapper {
    id: appList

    signal application(variant app)
    signal update()

    headerText: qsTr("Recently updated apps")

    property alias appsModel: appsModel

    function load() {
        Api.api.platform = appWindow.getCurrentPlatform();

        console.log("loading application list");
        var page = appList;
        page.application.connect(function(app) {
            stack.push(Qt.resolvedUrl("Application.qml"),{"application":app});
        });
        page.update.connect(function(){
            Api.apps.loadRecent(page);
        })
        Api.categories.preload(function(){
            page.update();
        });
    }
    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (pageStack._currentContainer.attachedContainer == null) {
                pageStack.pushAttached(Qt.resolvedUrl("Categories.qml"))
            }
        }
    }

    /*Timer{
        // since onCompleted does not work to push a page we wait some more before create Categories page
        running: true
        repeat: false
        interval: 500
        onTriggered: pageStack.pushAttached(Qt.resolvedUrl("Categories.qml"))
    }*/

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

    ListModel {
        id: appsModel
    }

    tools: Component {
        PullDownMenu {
            busy: isCheckForUpdatesRunning
            MenuItem {
                text: qsTr("My profile")
                onClicked: pageStack.push(Qt.resolvedUrl("Me.qml"))
            }
            MenuItem {
                text: enabled ? qsTr("Check updates") : qsTr("Checking for updates")
                enabled: !isCheckForUpdatesRunning
                onClicked: {
                    checkForUpdates();
                }
                BusyIndicator {
                    anchors{
                        right: parent.right
                        rightMargin: myTheme.paddingLarge * 2
                        verticalCenter: parent.verticalCenter
                    }
                    size: BusyIndicatorSize.Small
                    running: !parent.enabled
                    visible: !parent.enabled
                }
            }
            MenuItem {
                text: "Search app"
                onClicked: pageStack.push(Qt.resolvedUrl("Search.qml"))
            }
            MenuItem {
                text: "Refresh"
                onClicked: appList.update()
            }
        }
    }

    content: SilicaFlickable {
        id: appsFlickable
        anchors.fill: parent
        clip: true
        pressDelay: 0
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: myTheme.paddingSmall
            Repeater {
                model: appsModel
                delegate: appDelegate
            }
        }
        //ScrollDecorator{ flickable: appsFlickable }
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
