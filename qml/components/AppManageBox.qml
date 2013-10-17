import QtQuick 1.1
import com.nokia.meego 1.0

import "."

Column {
    property string repository: ""
    property bool isRepositoryEnabled: false
    property variant appstatus: {}
    property variant apppackage: {}

    property bool opInProgress: pkgManagerProxy.opInProgress
    property bool isInstalledFromLocalFile: appstatus.Repository === "local-file"
    property bool isInstalledFromOvi: appstatus.Origin === "com.nokia.maemo/ovi"
    property bool isInstalledNotFromOpenRepos: isInstalledFromOvi || isInstalledFromLocalFile
    property bool isInstalled: appstatus.Type === "Installed"
    property bool isNotInstalled: appstatus.Type === "NotInstalled"
    property bool isStateUnknown: appstatus.Type === undefined

    width: parent.width

    onApppackageChanged: {
        updateAppStatus();
    }
    onRepositoryChanged: {
        pkgManagerProxy.isRepositoryEnabled(repository,
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
        text: qsTr("Download size: %1 Kb").arg(appstatus.Size/1000)
        wrapMode: Text.Wrap
        visible: isNotInstalled && !opInProgress
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
            opInProgress = true;
            pkgManagerProxy.fetchRepositoryInfo();
        }
        visible: isRepositoryEnabled && isStateUnknown && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Enable repository")
        onClicked: {
            //enable repository
            if (repository != "") {
                pkgManagerProxy.enableRepository(repository);
                pkgManagerProxy.fetchRepositoryInfo();
                pkgManagerProxy.isRepositoryEnabled(repository, function(result) {
                    isRepositoryEnabled = result;
                });
                updateAppStatus();
            } else {
                appDetails.show_error("Unknown repository!");
            }
        }
        visible: repository!=="" && !isRepositoryEnabled && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Install")
        onClicked: {
            pkgManagerProxy.install(apppackage.name, updateAppStatus);
        }
        visible: isNotInstalled && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Re-Install")
        onClicked: {
            pkgManagerProxy.enableRepository(repository);
            pkgManagerProxy.uninstall(apppackage.name);
            pkgManagerProxy.install(apppackage.name, updateAppStatus);
        }
        visible: isInstalled && isInstalledNotFromOpenRepos && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Uninstall")
        onClicked: {
            pkgManagerProxy.uninstall(apppackage.name, updateAppStatus);
        }
        visible: isInstalled && !opInProgress
    }
    PkgManagerStatus {
        id: pkgStatus
    }

}

