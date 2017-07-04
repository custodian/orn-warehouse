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

    property var reposList: []
    property bool isCheckForUpdatesRunning: false
    property string transactionCheckForUpdates: ""
    property string transactionUpdateRepository: ""

    allowedOrientations: defaultAllowedOrientations
    _defaultPageOrientations: Orientation.All

    function checkForUpdates() {
        isCheckForUpdatesRunning = true;
        //TODO: check only for own repositories
        //pkgManagerProxy.refreshRepositoryInfo();
        reposList = [];
        transactionCheckForUpdates = pkgManagerProxy.getRepoList();
    }

    function getCurrentPlatform() {
        return "SailfishOS";
    }

    initialPage: Component {
        Applications {
            id: applicatiosPage
        }
    }
    cover: CoverBackground {

            Image {
		id: coverImage
                source: "../qml/images/cover.png"
                anchors.horizontalCenter: parent.horizontalCenter
                height: sourceSize.height * width / sourceSize.width
                opacity: 0.4
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: coverImage.bottom
                text: "Warehouse"
                font.bold: true
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

    QtObject {
        id: categotyParser
        function parse(category, style) {
            return Api.categories.parse(category, style);
        }
    }

    ThemeLoader {
        id: myTheme
    }

    RemorsePopup {
        id: remorse
    }
//    ProceedPopup {
//        id: updateProceed
//        onCanceled: {
//            pageStack.push("pages/AvailableUpdates.qml");
//        }
//    }

    PackageManagerProxy {
        id: pkgManagerProxy

        onUpdatesChanged: {
            //Make notification about updates available
            if (!isUpdateChannelEnabled || reposList.length == 0) {
                if (pageStack.currentPage.getUpdatesTransaction !== undefined) {
                    pageStack.currentPage.update();
                } else {
                    //updateProceed.execute("Updates available", function() {});
                    var obj = Qt.createComponent("components/ProceedPopup.qml").createObject(pageStack.currentPage)
                    obj.canceled.connect(function () {
                        pageStack.push("pages/AvailableUpdates.qml");
                        obj.destroy()
                    })
                    obj.triggered.connect(function () {
                        obj.destroy()
                    })
                    obj.execute("Updates available", function() {});
                }
            }
        }

        onTransactionRepoDetail: {
            switch(trname) {
            case getReposTransaction:
                if (repoid == "openrepos-basil") {
                    isUpdateChannelEnabled = true;
                }
                break;
            case transactionCheckForUpdates:
                if (repoid.indexOf("openrepos-")!== -1) {
                    reposList.push(repoid);
                }
                break;
            }
        }

        onTransactionFinished: {
            switch(trname) {
            case getReposTransaction:
                if (!isUpdateChannelEnabled) {
                    remorse.execute("Enabling self-update channel", function() {
                        pkgManagerProxy.enableRepository("basil");
                    });
                }
                getReposTransaction = "";
                break;
            case transactionCheckForUpdates:
                var repoid1 = reposList.pop();
                transactionUpdateRepository = pkgManagerProxy.refreshSingleRepositoryInfo(repoid1.replace("openrepos-",""));
                transactionCheckForUpdates = "";
                break;
            case transactionUpdateRepository:
                if (reposList.length) {
                    var repoid2 = reposList.pop();
                    transactionUpdateRepository = pkgManagerProxy.refreshSingleRepositoryInfo(repoid2.replace("openrepos-",""));
                } else {
                    isCheckForUpdatesRunning = false;
                    transactionUpdateRepository = "";
                }
                break;
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
