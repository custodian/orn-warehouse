import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appList

    signal update()

    property variant repositories: undefined

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Your profile")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        page.update.connect(function(){
            pkgManagerProxy.updateRepositoryList();
        });
        page.update();
    }
    function updateView() {
        update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Connections {
        target: pkgManager
        onRepositoryListChanged: {
            repositories = repos;
        }
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
                text: qsTr("Some weird stuff")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Enable test repos")
                onClicked: {
                    pkgManagerProxy.enableRepository("basil");
                    pkgManagerProxy.enableRepository("appsformeego");
                    pkgManagerProxy.enableRepository("knobtviker");
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Installed applications list")
                onClicked: {
                    stack.push(Qt.resolvedUrl("InstalledApps.qml"));
                }
            }

            SectionHeader {
                text: qsTr("Current operations")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Fetch repository info")
                enabled: !pkgStatus.opInProgress
                onClicked: {
                    pkgManagerProxy.fetchRepositoryInfo();
                }
            }
            PkgManagerStatus {
                id: pkgStatus
            }

            SectionHeader {
                text: qsTr("Enabled repositories")
            }

            Repeater {
                width: parent.width
                model: repositories
                delegate: repositoryDelegate
            }
        }
    }

    Component {
        id: repositoryDelegate

        Item {
            width: reposColumn.width
            height: disableButton.height + 10
            Text {
                id: repoName
                anchors{
                    left: parent.left
                    right: refreshButton.left
                    margins: mytheme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: mytheme.fontSizeLarge
                maximumLineCount: 2
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                text: modelData.name
            }
            Button {
                id: refreshButton
                anchors {
                    right: disableButton.left
                    rightMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                width: 120
                text: qsTr("Refresh")
                enabled: !pkgManagerProxy.opInProgress
                onClicked: pkgManagerProxy.fetchRepositoryInfo(modelData.name);
            }

            Button {
                id: disableButton
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                width: 120
                text: qsTr("Disable")
                onClicked: pkgManagerProxy.disableRepository(modelData.name);
            }
        }
    }
}
