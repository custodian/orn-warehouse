import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: root

    signal update()

    property variant selectedApp: undefined

    property string getReposTransaction: ""

    width: parent.width
    height: parent.height

    headerText: qsTr("Your profile")

    function load() {
        var page = root;
        page.update.connect(function(){
            page.waiting_show();
            reposModel.clear();
            getReposTransaction = pkgManagerProxy.getRepoList();
        });
        page.update();
    }
    function updateView() {
        update();
    }

    Connections {
        target: pkgManagerProxy
        onRepoListChanged: {
            root.update();
        }
        onTransactionRepoDetail: {
            if (trname == getReposTransaction) {
                if (repoid.indexOf("openrepos-")!== -1) {
                    reposModel.append({"name":repoid.replace("openrepos-",""), "repoenabled": repoenabled});
                }
            }
        }
        onTransactionFinished: {
            switch(trname) {
            case getReposTransaction:
                root.waiting_hide();
                getReposTransaction = "";
                break;
            }
        }
    }

    ListModel {
        id: reposModel
    }

    content: SilicaFlickable{
        id: flickableArea
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
                text: qsTr("Installed applications")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Show updates")
                enabled: !pkgStatus.transactionCount
                onClicked: {
                    stack.push("AvailableUpdates.qml");
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("View full list")
                onClicked: {
                    stack.push(Qt.resolvedUrl("InstalledApps.qml"));
                }
            }

            SectionHeader {
                text: qsTr("Current operations")
            }
            PkgManagerStatus {
                id: pkgStatus
                showPending: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                text: qsTr("Queue is empty")
                visible: !pkgStatus.transactionCount
            }

            SectionHeader {
                text: qsTr("Enabled repositories")
            }
            Column {
                id: repeaterColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: myTheme.paddingMedium
                }
                spacing: myTheme.paddingLarge
                Repeater {
                    model: reposModel
                    delegate: reposDelegate
                }
            }

            Component {
                id: reposDelegate

                Text {
                    id: reposLabel
                    width: repeaterColumn.width
                    color: myTheme.primaryColor
                    font.pixelSize: myTheme.fontSizeMedium
                    text: model.name
                    Button {
                        text: qsTr("Disable")
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            //remorse.execute(/*reposLabel, */qsTr("Removing"), function() {
                                pkgManagerProxy.disableRepository(model.name)
                            //});
                        }
                    }
                }
            }
        }
    }

    RemorsePopup {
        id: remorse
        onTriggered: {
            root.update();
        }
    }

}
