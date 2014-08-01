import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Page {
    id: pageWrapper

    signal headerClicked

    property alias pagetop: pageHeader.bottom
    property bool busy: false
    property alias headerText: pageHeader.title
    property alias tools: pullDownLoader.sourceComponent
    property alias content: contentLoader.sourceComponent
    property alias loadedContent: contentLoader.item
    property alias stack: pageWrapper.pageContainer

    Component.onCompleted: {
        if (pageWrapper.load)
            pageWrapper.load()
    }

    SilicaFlickable {
        id: flicable
        anchors.fill: parent
        pressDelay: 0

        Loader {
            id: pullDownLoader
        }

        PageHeader {
            id: pageHeader

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    headerClicked()
                }
                visible: true
            }
        }

        Item {
            anchors {
                top: pageHeader.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            opacity: busy ? 0.5 : 1
            Loader {
                id: contentLoader
                anchors.fill: parent
            }
            //ScrollDecorator{ flickable: contentLoader.item }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: busy
        visible: busy
        z: 5
    }

    function waiting_show() {
        busy = true;
    }

    function waiting_hide() {
        busy = false;
    }


    function show_error(msg) {
        show_error_base(msg);
    }

    function show_error_base(msg){
        waiting_hide();
        console.log("Error: "+ msg);
        //infoBanner.text = msg;
        //infoBanner.show();
        /*
        notificationDialog.message += msg + "<br/>"
        notificationDialog.state = "shown";
        notificationDialog.hider.restart();
        */
    }

    function show_info(msg) {
        //notificationDialog.message = msg
        //notificationDialog.state = "shown";
    }

    /*function updateNotificationCount(value) {
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
    }*/
}
