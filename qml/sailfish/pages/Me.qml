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
                }
                //spacing: myTheme.paddingLarge
                Repeater {
                    model: reposModel
                    delegate: reposDelegate
                }
            }

            Component {
                id: reposDelegate

                ListItem {
                    id: listItem
                    menu: contextMenu
                    contentHeight: Theme.itemSizeSmall // two line delegate
                    ListView.onRemove: animateRemoval(listItem)

                    function remove() {
                        remorseAction("Disabling repository", function() {
                            //view.model.remove(index) }
                            pkgManagerProxy.disableRepository(model.name);
                        });
                    }
                    function refresh() {
                        pkgManagerProxy.refreshSingleRepositoryInfo(model.name);
                    }

                    Label {
                        id: reposLabel
                        anchors.centerIn: parent
                        //width: repeaterColumn.width
                        color: myTheme.primaryColor
                        //font.pixelSize: myTheme.fontSizeMedium
                        text: model.name
                        /*Button {
                            text: model.repoenabled ? qsTr("Disable") : qsTr("Enable")
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            onClicked: {
                                //remorse.execute(//reposLabel,
                                qsTr("Removing"), function() {
                                model.repoenabled
                                    ? pkgManagerProxy.disableRepository(model.name)
                                    : pkgManagerProxy.enableRepository(model.name)
                                //});
                            }
                        }
                        */
                    }

                    Component {
                        id: contextMenu
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Refresh")
                                onClicked: refresh()
                            }
                            MenuItem {
                                text: qsTr("Disable")
                                onClicked: remove()
                            }
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: flickableArea}
    }

    RemorsePopup {
        id: remorse
        onTriggered: {
            root.update();
        }
    }

}
