import "../js/api.js" as Api

//TODO: change to this
//import net.thecust.aui 1.0
//import "../components"

import QtQuick 2.0
import Sailfish.Silica 1.0

//import net.thecust.packagekit 1.0
import "../components-jolla"

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

/*
PageStackWindow {
    initialPage: mainPage
    showStatusBar: inPortrait
    showToolBar: tabgroup.currentTab !== tabLogin || tabLogin.depth > 1

    property bool windowActive: Qt.application.active
    property alias stack: tabgroup.currentTab;
    property int notificationsCount: 0

    property string platform: appWindow.getCurrentPlatform()
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
                    tabApps.push(Qt.resolvedUrl("Apps.qml"))
                }
            }

            PageStack {
                id: tabCategories
                function load() {
                    tabCategories.push(Qt.resolvedUrl("Categories.qml"))
                }
            }

            PageStack {
                id: tabSearch
                function load() {
                    tabSearch.push(Qt.resolvedUrl("Search.qml"))
                }
            }

            PageStack {
                id: tabMe
                function load() {
                    tabMe.push(Qt.resolvedUrl("Me.qml"))
                }
            }


            PageStack {
                id: tabLogin
                function load() {
                    tabLogin.clear();
                    tabLogin.push(Qt.resolvedUrl("Welcome.qml"),{"newuser":true},true);
                }
            }
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
        stack.push(Qt.resolvedUrl("Notifications.qml"));
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
        target: appTranslator
        onLanguageChanged: appWindow.onLanguageChanged(language)
    }
}
*/
