import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: root

    signal update()

    property variant selectedApp: undefined

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Your profile")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = root;
        page.update.connect(function(){
            page.waiting_show();
            appsModel.clear();
            pkgManagerProxy.getInstalledPackages(true, function(packages) {
                page.waiting_hide();
                packages.forEach(function(pkg) {
                    var application = { "application" : pkg };
                    appsModel.append(application);
                });
            });
        });
        page.update();
    }
    function updateView() {
        update();
    }

    ListModel {
        id: appsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            id: reposColumn
            width: parent.width
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            SectionHeader {
                text: qsTr("Current operations")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Fetch repository info")
                enabled: !pkgManagerProxy.opInProgress
                onClicked: {
                    pkgManagerProxy.fetchRepositoryInfo();
                }
            }
            PkgManagerStatus {
                id: pkgStatus
            }

            SectionHeader {
                text: qsTr("Installed applications")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("View full list")
                onClicked: {
                    stack.push(Qt.resolvedUrl("InstalledApps.qml"));
                }
            }
            SectionHeader {
                text: qsTr("Installed via Warehouse")
            }
            Repeater {
                width: parent.width
                model: appsModel
                delegate: appDelegate
            }
        }
    }

    Component {
        id: appDelegate

        PackageBox {
            application: model.application
            width: reposColumn.width

            onAreaClicked: {
                stack.push(Qt.resolvedUrl("PkgInfo.qml"), {"pkg" : model.application, "warehouse": true, "parentPage": root});
            }
        }
    }
}
