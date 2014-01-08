import QtQuick 2.0
import Sailfish.Silica 1.0

import "."

Column {
    id: root

    width: parent.width

    property variant appPackage

    property string repositoryName: ""
    property string repositoryDescription: ""
    property string repositoryTransaction: ""

    property bool isRepositoryEnabled: false
    property bool isPackagePlanned: false

    property bool isStateKnown: false
    property string packageStateTransaction: ""

    property bool isInProgress: packageActionTransaction !== ""
    property string packageActionTransaction: ""

    property bool isInstalledFromOther: false
    property bool isInstalledFromThis: false
    property bool isInstalled: isInstalledFromThis || isInstalledFromOther
    property bool isUpdateAvailable: false

    property variant appInstalled
    property variant appAvailable

    property int downloadSize: 0 //appStatus.DownloadSize ? appStatus.DownloadSize : appStatus.Size ? appStatus.Size : 0
    property string downloadSizeTransaction: ""

    onAppPackageChanged: {
        if (appPackage !== undefined) {
            updateAppStatus();
        }
    }

    function resetState() {
        appInstalled = undefined;
        appAvailable = undefined;
        isUpdateAvailable = false;
        isInstalledFromOther = false;
        isInstalledFromThis = false;
        isStateKnown = false;
        isRepositoryEnabled = false;
        downloadSize = 0;
    }

    function updateAppStatus() {
        resetState();
        repositoryTransaction = pkgManagerProxy.getRepoList();
        if (appPackage.name !== undefined) {
            packageStateTransaction = pkgManagerProxy.searchName(appPackage.name);
        }
    }

    Connections {
        target: pkgManagerProxy
        onTransactionRepoDetail: {
            if (trname == repositoryTransaction) {
                if (repoid == "openrepos-"+repositoryName) {
                    isRepositoryEnabled = repoenabled;
                }
            }
        }
        onTransactionDetails: {
            if (trname == downloadSizeTransaction) {
                downloadSize = pkgsize;
            }
        }
        onTransactionPackage: {
            if (trname == packageStateTransaction) {
                if (pkgobject.data === "openrepos-"+repositoryName) {
                    switch(pkgstatus) {
                    case "available":
                        if (appAvailable === undefined || appAvailable.version < pkgobject.version) {
                            appAvailable = pkgobject;
                        }
                        break;
                    case "installed":
                        isInstalledFromThis = true;
                        appInstalled = pkgobject;
                        break;
                    }
                } else {
                    if (pkgstatus === "installed") {
                        isInstalledFromOther = true;
                        appInstalled = pkgobject;
                    }
                }
            }
        }
        onTransactionFinished: {
            switch(trname) {
            case packageStateTransaction:
                if (isInstalled && appAvailable !== undefined) {
                    if (appAvailable.version > appInstalled.version) {
                        isUpdateAvailable = true;
                    }
                }
                if (!isInstalled && appAvailable !== undefined) {
                    downloadSizeTransaction = pkgManagerProxy.packageDetails(appAvailable.packageid);
                }
                isStateKnown = true;
                packageStateTransaction = "";
                break;
            case repositoryTransaction:
                repositoryTransaction = "";
                break;
            case packageActionTransaction:
                updateAppStatus();
                packageActionTransaction = "";
                break;
            case downloadSizeTransaction:
                downloadSizeTransaction = ""
                break;
            }
        }

        onRepoListChanged: {
            updateAppStatus();
        }
    }

    RemorsePopup {
        id: remorse
    }
    Column {
        width: parent.width
        visible: !isPackagePlanned

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            text: qsTr("Installed: %1").arg(appInstalled ? appInstalled.version : "")
            wrapMode: Text.Wrap
            visible: isInstalled
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            text: qsTr("Available: %1").arg(appAvailable ? appAvailable.version : "")
            wrapMode: Text.Wrap
            visible: isUpdateAvailable
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            text: qsTr("Download size: %1 Kb").arg(downloadSize/1000)
            wrapMode: Text.Wrap
            visible: (!isInstalled || isUpdateAvailable) && downloadSize
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Enable Repository")
            onClicked: {
                isStateKnown = false;
                pkgManagerProxy.enableRepository(repositoryName);
            }
            visible: !isRepositoryEnabled && isStateKnown
        }
        Column {
            width: parent.width

            visible: isStateKnown && !isInProgress

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Install")
                onClicked: {
                    //remorse.execute(qsTr("Installing %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.installPackage(appAvailable.packageid);
                    //});
                }
                visible: isRepositoryEnabled && !isInstalled
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Re-Install")
                onClicked: {
                    //remorse.execute(qsTr("Re-Installing %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.installPackage(appAvailable.packageid);
                    //});
                }
                visible: isInstalledFromOther && isUpdateAvailable
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Upgrade")
                onClicked: {
                    //remorse.execute(qsTr("Upgrade %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.updatePackage(appAvailable.packageid);
                    //});
                }
                visible: isInstalledFromThis && isUpdateAvailable
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Uninstall")
                onClicked: {
                    //remorse.execute(qsTr("Uninstall %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.removePackage(appInstalled.packageid);
                    //});
                }
                visible: isInstalled
            }
        }
    }

    PkgManagerStatus {
        id: pkgStatus

        onBusyStatusChanged: {
            updateAppStatus();
        }
    }
}

/*
Column {
    id: root

    property string repositoryName: ""
    property bool isRepositoryEnabled: false
    property variant appstatus: {}
    property variant apppackage: {}

    property bool opInProgress: pkgManagerProxy.opInProgress
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
        visible: isInstalled && isInstalledNotFromOpenRepos && isRepositoryEnabled && !opInProgress
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


}
*/
