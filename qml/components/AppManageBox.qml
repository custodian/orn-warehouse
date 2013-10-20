import QtQuick 1.1
import com.nokia.meego 1.0

import "."

Column {
    id: root

    property string repositoryName: ""
    property bool isRepositoryEnabled: false
    property variant appstatus: {}
    property variant apppackage: {}

    property bool opInProgress: pkgManagerProxy.opInProgress || pkgStatus.localOperation
    property bool isInstalledFromLocalFile: appstatus.Repository === "local-file"
    property bool isInstalledFromOvi: appstatus.Origin === "com.nokia.maemo/ovi"
    property bool isInstalledNotFromOpenRepos: isInstalledFromOvi || isInstalledFromLocalFile
    property bool isInstalled: appstatus.Type === "Installed"
    property bool isUpdateAvailable: appstatus.Type === "Update"
    property bool isNotInstalled: appstatus.Type === "NotInstalled"
    property bool isStateUnknown: appstatus.Type === undefined
    property int downloadSize: appstatus.DownloadSize ? appstatus.DownloadSize : appstatus.Size ? appstatus.Size : 0

    width: parent.width

    onApppackageChanged: {
        updateAppStatus();
    }
    onRepositoryNameChanged: {
        pkgManagerProxy.isRepositoryEnabled(repositoryName,
            function(result) {
                isRepositoryEnabled = result;
            });
    }

    function updateAppStatus() {
        if (apppackage.name !== undefined) {
            pkgManagerProxy.getPackageInfo( apppackage.name,
                function(result) {
                    if (result !== false) {
                        appstatus = result;
                    }
                });
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: mytheme.colors.textColorShout
        font.pixelSize: mytheme.font.sizeHelp
        text: qsTr("Version: %1").arg(appstatus.Version)
        wrapMode: Text.Wrap
        visible: !isStateUnknown && !opInProgress
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: mytheme.colors.textColorShout
        font.pixelSize: mytheme.font.sizeHelp
        text: qsTr("Download size: %1 Kb").arg(downloadSize/1000)
        wrapMode: Text.Wrap
        visible: (isNotInstalled || isUpdateAvailable) && !opInProgress
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: mytheme.colors.textColorShout
        font.pixelSize: mytheme.font.sizeHelp
        text: qsTr("Installed from OVI-Store")
        wrapMode: Text.Wrap
        visible: isInstalledFromOvi && !opInProgress
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: mytheme.colors.textColorShout
        font.pixelSize: mytheme.font.sizeHelp
        text: qsTr("Installed from Local File")
        wrapMode: Text.Wrap
        visible: isInstalledFromLocalFile && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Fetch repository info")
        onClicked: {
            pkgManagerProxy.fetchRepositoryInfo(repositoryName);
        }
        visible: isRepositoryEnabled && isStateUnknown && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Enable repository")
        onClicked: {
            if (repositoryName != "") {
                pkgManagerProxy.enableRepository(repositoryName);
                pkgManagerProxy.isRepositoryEnabled(repositoryName, function(result) {
                    isRepositoryEnabled = result;
                });
                pkgManagerProxy.fetchRepositoryInfo(repositoryName, function(result){
                    updateAppStatus();
                });
            } else {
                appDetails.show_error("Unknown repository!");
            }
        }
        visible: repositoryName!=="" && !isRepositoryEnabled && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Install")
        onClicked: {
            pkgManagerProxy.install(apppackage.name, function(result) {
                updateAppStatus();
            });
        }
        visible: isNotInstalled && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Re-Install")
        onClicked: {
            pkgManagerProxy.enableRepository(repositoryName);
            pkgManagerProxy.uninstall(apppackage.name);
            pkgManagerProxy.fetchRepositoryInfo(repositoryName);
            pkgManagerProxy.install(apppackage.name, function(result){
                updateAppStatus();
            });
        }
        visible: isInstalled && isInstalledNotFromOpenRepos && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Upgrade")
        onClicked: {
            pkgManagerProxy.upgrade(apppackage.name, function(result){
                updateAppStatus();
            });
        }
        visible: isUpdateAvailable && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Uninstall")
        onClicked: {
            pkgManagerProxy.uninstall(apppackage.name, function(result){
                updateAppStatus();
            });
        }
        visible: isInstalled && !opInProgress
    }
    PkgManagerStatus {
        id: pkgStatus

        onLocalOperationChanged: {
            updateAppStatus();
        }

    }

}

