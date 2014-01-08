import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages-jolla"
import "components-jolla"

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
        Applications { }
    }
    cover: CoverBackground {
        Label {
            id: label
            anchors.centerIn: parent
            text: "Warehouse"
        }

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: "image://theme/icon-cover-sync"
            }

            CoverAction {
                iconSource: "image://theme/icon-cover-search"
            }
        }
    }

    Component.onCompleted: {
        getReposTransaction = pkgManagerProxy.getRepoList();
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

    PackageManagerProxy {
        id: pkgManagerProxy

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
            pageStack.push("components-jolla/ErrorDialog.qml", {"trName": trname, "trStatus":trstatus, "trMessage":trmessage});
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

/*import QtQuick 1.1
import com.nokia.meego 1.0

import "js/api.js" as Api
import "components"

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    showStatusBar: inPortrait
    showToolBar: tabgroup.currentTab !== tabLogin || tabLogin.depth > 1

    property bool windowActive: Qt.application.active
    property alias stack: tabgroup.currentTab;
    property int notificationsCount: 0

    property string platform: getCurrentPlatform()
    function getCurrentPlatform() {
        return "Harmattan";
        //return "SailfishOS";
    }
    onPlatformChanged: {
        Api.api.platform = platform;
    }

    Component.onCompleted: {
        mytheme.loadTheme("light");
        pkgManagerProxy.getPackageInfo("openrepos-source-policy", function(result) {
            if (result !== false) {
                console.log("Source policy version: " + result.Version);
            } else {
                console.log("Source policy is not installed!");
                pkgManagerProxy.installSourcePolicy();
            }
        });
    }

    onWindowActiveChanged: {
        //console.log("active: " + windowActive);
    }

    Configuration {
        id: configuration
        onLanguageChanged: {
            appTranslator.changeLanguage(language);
        }
    }

    Page {
        id: mainPage
        orientationLock: PageOrientation.LockPortrait
        tools: stack.currentPage !== null ? stack.currentPage.tools : null

        onToolsChanged: {
            if (pageStack) {
                pageStack.toolBar.tools = tools;
            }
        }

        TabGroup {
            id: tabgroup
            currentTab: tabApps//tabLogin
            anchors.fill: parent

            property variant lastTab

            onCurrentTabChanged: {
                if (currentTab.depth === 0) {
                    currentTab.load();
                }
            }

            PageStack {
                id: tabApps
                function load() {
                    tabApps.push(Qt.resolvedUrl("pages/Apps.qml"))
                }
            }

            PageStack {
                id: tabCategories
                function load() {
                    tabCategories.push(Qt.resolvedUrl("pages/Categories.qml"))
                }
            }

            PageStack {
                id: tabSearch
                function load() {
                    tabSearch.push(Qt.resolvedUrl("pages/Search.qml"))
                }
            }

            PageStack {
                id: tabMe
                function load() {
                    tabMe.push(Qt.resolvedUrl("pages/Me.qml"))
                }
            }


            PageStack {
                id: tabLogin
                function load() {
                    tabLogin.clear();
                    tabLogin.push(Qt.resolvedUrl("pages/Welcome.qml"),{"newuser":true},true);
                }
            }
        }
    }

    QtObject {
        id: categotyParser
        function parse(category, style) {
            return Api.categories.parse(category, style);
        }
    }

    ThemeLoader {
        id: mytheme

        onInvertedChanged: {
            Api.api.inverted = inverted;
        }
    }

    ToolBarLayout {
        id: commonTools
        ToolIcon {
            iconId: stack.depth > 1 ? "toolbar-back" : "toolbar-back-dimmed"//toolbar-refresh"
            //iconId: "toolbar-back"
            onClicked: {
                if (stack.depth > 1)
                    stack.pop();
            }
        }
        ButtonRow {
            style: TabButtonStyle {}

            TabButtonIcon {
                platformIconId: "toolbar-home"
                tab: tabApps
                onClicked: popToTop(tabApps);
            }
            TabButtonIcon {
                platformIconId: "toolbar-list"
                tab: tabCategories
                onClicked: popToTop(tabCategories);
            }
            TabButtonIcon {
                platformIconId: "toolbar-search"
                tab: tabSearch
                onClicked: popToTop(tabSearch);
            }
            TabButtonIcon {
                platformIconId: "toolbar-contact"
                tab: tabMe
                onClicked: popToTop(tabMe);
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                if (stack.currentPage.pageMenu !== undefined) {
                    stack.currentPage.pageMenu.open();
                } else {
                    dummyMenu.createObject(mainPage).open();
                }
            }
        }
    }

    UpdateDialog {
        id: updateDialog
        z: 30
    }

    function popToTop(tab) {
        if (tabgroup.lastTab === tab) {
            if (tab.depth === 1) {
                if (tab.currentPage.updateView !== undefined)
                    tab.currentPage.updateView();
            } else {
                while (tab.depth > 1) {
                    tab.pop(tab.depth > 2);
                }
            }
        }
        tabgroup.lastTab = tab;
    }

    function processUINotification(id) {
        stack.push(Qt.resolvedUrl("pages/Notifications.qml"));
    }

    function processURI(url) {
        console.log("Process URI: " + url);
        var params = url.split("/");
        var type = params[0];
        var id = params[1];
        var operation = params[2];

        popToTop(tabgroup.currentTab);
        switch(type) {
        case "client":
            openStartPage();
            if (id === "start") {
                popToTop(tabgroup.currentTab);
            }
            break;
        case "apps":
            console.log("Should work with application: " + id + " operation: " + operation);
            var app = {
                "appid":id,
                "title": "Loading...",
                "user": {
                    "name": "Loading...",
                },
                "category": []
            };
            stack.push(Qt.resolvedUrl("pages/Application.qml"), {"application": app});
            break;
        default:
            console.log("Unimplemented callback for content: " + type);
            break;
        }
    }

    function reloadUI() {
        tabLogin.clear();
        tabApps.clear();
        tabCategories.clear();
        tabSearch.clear();
        tabMe.clear();
        tabgroup.currentTab.load();
    }

    function onLanguageChanged(language) {
        reloadUI();
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
    PkgManagerProxy{
        id: pkgManagerProxy
    }
    function msgCallbackFunction(msg) {
        console.log("In msgCallbackFunction");
        try {
            pkgManagerProxy.processAction(msg);
        } catch (err) {
            console.log("execute error:" + err);
        }
    }

    Connections {
       target: imageCache
       onCacheUpdated: appWindow.onCacheUpdated(callback, status, url)
    }
    Connections {
        target: appTranslator
        onLanguageChanged: appWindow.onLanguageChanged(language)
    }
}
*/
