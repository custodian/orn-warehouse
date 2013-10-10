import QtQuick 1.1
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

    Component.onCompleted: {
        mytheme.loadTheme("light");
    }

    onWindowActiveChanged: {
        console.log("active: " + windowActive);
    }

    Page {
        id: mainPage

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
            /*anchors {
                top: pageHeader.bottom;
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }*/
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
        console.log("uri: " + url);
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
        case "application":
            console.log("Should work with application: " + type);
            break;
        default:
            console.log("Unimplemented callback for content: " + type);
            break;
        }
    }

    function reloadUI() {
        platformUtils.clearFeed();
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

    /*Connections {
       target: cache
       onCacheUpdated: appWindow.onCacheUpdated(callback, status, url)
    }*/
}
