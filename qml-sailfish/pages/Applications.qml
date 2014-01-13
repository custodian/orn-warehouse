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

    //headerText: qsTr("Recently updated apps")

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
        page.update();
    }

    /*onHeaderClicked: {
        loadedContent.scrollToTop();
    }*/

    ListModel {
        id: appsModel
    }

    SilicaListView {
        id: appsListView
        anchors.fill: parent
        model: appsModel
        delegate: appDelegate
        clip: true
        header: PageHeader {
            title: qsTr("Recently updated apps")
        }

        spacing: myTheme.paddingSmall

        PullDownMenu {
            MenuItem {
                text: "My profile"
                onClicked: pageStack.push(Qt.resolvedUrl("Me.qml"))
            }
            MenuItem {
                text: "Categories"
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
