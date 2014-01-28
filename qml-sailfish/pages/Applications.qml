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

    property string refreshCacheTransaction: ""

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
        page.update();
    }

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

    ListModel {
        id: appsModel
    }

    Connections {
        target: pkgManagerProxy
        onTransactionFinished: {
            if (trname == refreshCacheTransaction) {
                refreshCacheTransaction = "";
            }
        }
        onTransactionListChanged: {
            transactionList.forEach(function(transaction) {
                if (transaction.role == "refresh-cache") {
                    refreshCacheTransaction = transaction.name;
                }
            });
        }
    }

    tools: Component {
        PullDownMenu {
            MenuItem {
                text: "My profile"
                onClicked: pageStack.push(Qt.resolvedUrl("Me.qml"))
            }
            MenuItem {
                text: "Check updates"
                enabled: !refreshCacheTransaction.length
                onClicked: {
                    pkgManagerProxy.refreshRepositoryInfo();
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
                text: "Browse by categories"
                onClicked: pageStack.push(Qt.resolvedUrl("Categories.qml"))
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
        ScrollDecorator{ flickable: appsFlickable }
    }

    Component {
        id: appDelegate

        ApplicationBox {
            id: appbox
            application: model.application

            onClicked: {
                appList.application( model.application );
            }
        }
    }
}
