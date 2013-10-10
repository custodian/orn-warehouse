import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "."

Page {
    id: pageWrapper

    width: parent.width
    height: parent.height

    property string color
    property alias pagetop: pageHeader.bottom

    tools : commonTools
    property QtObject pageMenu: defaultMenu
    property alias headerText: pageHeader.headerText
    property alias headerIcon: pageHeader.headerIcon
    property alias headerBubble: pageHeader.countBubbleVisible
    orientationLock: mainPage.orientationLock

    signal headerSelectedItem(int index)

    Component.onCompleted: {
        if (pageWrapper.load)
            pageWrapper.load()
    }

    PageHeader {
        id: pageHeader
        z: 1
        headerText: "Awesome header";

        /*onSelectedItem: {
            pageWrapper.headerSelectedItem(index);
        }*/
        visible: headerText.length > 0
    }

    InfoBanner {
        id: infoBanner
        z: 1
        anchors.top: pagetop
        property bool shown: false
        topMargin: 10
    }

    function waiting_show() {
        pageHeader.busy = true;
    }

    function waiting_hide() {
        pageHeader.busy = false;
    }


    function show_error(msg) {
        show_error_base(msg);
    }

    function show_error_base(msg){
        waiting_hide();
        console.log("Error: "+ msg);
        infoBanner.text = msg;
        infoBanner.show();
        /*
        notificationDialog.message += msg + "<br/>"
        notificationDialog.state = "shown";
        notificationDialog.hider.restart();
        */
    }

    function show_info(msg) {
        notificationDialog.message = msg
        notificationDialog.state = "shown";
    }

    function updateRateLimit(value) {
        configuration.ratelimit = value;
    }

    function updateNotificationCount(value) {
        appWindow.notificationsCount = value
        //console.log("last: " + lastNotiCount + " new: " + value);
        if (configuration.feedNotification!=="0") {
            if (value != appWindow.lastNotiCount) {
                platformUtils.removeNotification("openrepos.notification");
                if (value != "0") {
                    platformUtils.addNotification("openrepos.notification", "Openrepos", value + " new notification" +((value=="1")?"":"s"), 1);
                }
                appWindow.lastNotiCount = value;
            }
        }
    }

    Menu {
        id: defaultMenu
        MenuLayout {
            MenuItem {
                text: qsTr("Check updates")
                onClicked: {
                    updateDialog.getupdates();
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    stack.push(Qt.resolvedUrl("../pages/Settings.qml"));
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onClicked: {
                    //TODO:
                    //windowHelper.disableSwype(false);
                    Qt.quit();
                }
            }
        }
    }
}
