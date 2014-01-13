import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: root
    signal update()

    property string getAppsTransaction: ""

    width: parent.width
    height: parent.height

    headerText: qsTr("Installed applications")

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

    function load() {
        var page = root;
        page.update.connect(function(){
            page.waiting_show();
            appsModel.clear();
            getAppsTransaction = pkgManagerProxy.getInstalledApps();
        })
        page.update();
    }

    Connections {
        target: pkgManagerProxy
        onTransactionPackage: {
            if (trname == getAppsTransaction) {
                appsModel.append({"application":pkgobject});
                //console.log("PACKAGE STATUS", JSON.stringify(pkgobject), pkgstatus, pkgsummary )
            }
        }
        onTransactionFinished: {
            switch(trname) {
            case getAppsTransaction:
                root.waiting_hide();
                getAppsTransaction = "";
                break;
            }
        }
    }

    ListModel {
        id: appsModel
    }

    content: SilicaListView {
        model: appsModel
        delegate: appDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
    }

    Component {
        id: appDelegate

        PackageBox {
            application: model.application

            /*onAreaClicked: {
                stack.push(Qt.resolvedUrl("PkgInfo.qml"), {"pkg" : model.application, "warehouse": false, "parentPage": root});
            }*/
        }
    }
}
