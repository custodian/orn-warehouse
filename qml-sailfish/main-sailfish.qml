import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "components"

import net.thecust.packagekit 1.0

import "js/api.js" as Api

ApplicationWindow
{
    id: appWindow

    property string getReposTransaction: ""
    property bool isUpdateChannelEnabled: false

    function getCurrentPlatform() {
        return "SailfishOS";
    }

    initialPage: Component {
        Applications {
            id: applicatiosPage
        }
    }
    cover: CoverBackground {
        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: Theme.paddingMedium

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "/usr/share/icons/hicolor/86x86/apps/harbour-warehouse.png"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Warehouse"
            }
        }

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: "image://theme/icon-cover-search"
                onTriggered: {
                    //coverActionSearch();
                    while(pageStack.depth>1) {
                        pageStack.pop(undefined, PageStackAction.Immediate);
                    }
                    appWindow.activate();
                    pageStack.push("pages/Search.qml");
                }
            }
            CoverAction {
                iconSource: "image://theme/icon-cover-refresh"
                onTriggered: {
                    //coverActionRefresh();
                    while(pageStack.depth>1) {
                        pageStack.pop(undefined, PageStackAction.Immediate);
                    }
                    appWindow.activate();
                    pageStack.push("pages/AvailableUpdates.qml");
                }
            }
        }
    }

    Component.onCompleted: {
        getReposTransaction = pkgManagerProxy.getRepoList();
        pkgManagerProxy.getUpdatesList();
    }

    ThemeLoader {
        id: myTheme
    }

    RemorsePopup {
        id: remorse
    }
    ProceedPopup {
        id: updateProceed
        onCanceled: {
            pageStack.push("pages/AvailableUpdates.qml");
        }
    }

    PackageManagerProxy {
        id: pkgManagerProxy

        onUpdatesChanged: {
            //Make notification about updates available
            if (pageStack.currentPage.getUpdatesTransaction !== undefined) {
                pageStack.currentPage.update();
            } else {
                updateProceed.execute("Updates available", function() {});
            }
        }

        onTransactionRepoDetail: {
            if (trname == getReposTransaction) {
                if (repoid == "openrepos-basil") {
                    isUpdateChannelEnabled = true;
                }
            }
        }

        onTransactionFinished: {
            if (trname == getReposTransaction) {
                if (!isUpdateChannelEnabled) {
                    remorse.execute("Enabling self-update channel", function() {
                        pkgManagerProxy.enableRepository("basil");
                    });
                }
            }
        }

        onTransactionError: {
            pageStack.push("components/ErrorDialog.qml", {"trName": trname, "trStatus":trstatus, "trMessage":trmessage});
        }
    }

    function onCacheUpdated(callbackObject, status, url) {
        //console.log("Cache update callback: type: " + typeof(callbackObject) + " status: " + status + " url: " + url );
        try {
            if (typeof(callbackObject) === "function") {
                //console.log("funtion!");
                callbackObject(status,url);
            } else if (typeof(callbackObject) === "object") {
                //console.log("object!");
                if (callbackObject.cacheCallback !== undefined) {
                    callbackObject.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
            } else if (typeof(callbackObject) === "string") {
                //console.log("string!");
                var obj = Api.objs.get(callbackObject);
                if (obj.cacheCallback !== undefined) {
                    obj.cacheCallback(status,url);
                } else {
                    console.log("object callback is undefined!");
                }
                Api.objs.remove(callbackObject);
            } else {
                console.log("type is: " + typeof(callbackObject));
            }
        } catch (err) {
            console.log("Cache callback error: " + err + " type: " + typeof(callbackObject) + " value: " + JSON.stringify(callbackObject) );
        }
    }
    Connections {
       target: imageCache
       onCacheUpdated: appWindow.onCacheUpdated(callback, status, url)
    }
}
