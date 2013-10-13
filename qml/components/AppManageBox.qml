import QtQuick 1.1
import com.nokia.meego 1.0

import "."

Column {
    property string repository: ""
    property bool repository_enabled: false
    property variant appstatus: {}
    property variant apppackage: {}

    property bool opInProgress: false

    width: parent.width

    onApppackageChanged: {
        updateAppStatus();
        //console.log("HARMATTAN PACKAGE: " + JSON.stringify(apppackage));
    }
    onRepositoryChanged: {
        repository_enabled = pkgManager.isRepositoryEnabled(repository);
    }

    function updateAppStatus() {
        var result = pkgManager.getPackageInfo(apppackage.name);
        if (result !== false) {
            appstatus = result;
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Fetch repository info")
        onClicked: {
            pkgManager.fetchRepositoryInfo();
        }
        visible: repository_enabled && appstatus.Type === undefined && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Enable repository")
        onClicked: {
            //enable repository
            if (repository != "") {
                pkgManager.enableRepository(repository);
                pkgManager.fetchRepositoryInfo();
                repository_enabled = pkgManager.isRepositoryEnabled(repository);
                updateAppStatus();
            } else {
                appDetails.show_error("Unknown repository!");
            }
        }
        visible: repository!=="" && !repository_enabled && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Install")
        onClicked: {
            //install
            pkgManager.install(apppackage.name);
        }
        visible: appstatus.Type === "NotInstalled" && !opInProgress
    }
    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Uninstall")
        onClicked: {
            //uninstall
            pkgManager.uninstall(apppackage.name);
        }
        visible: appstatus.Type === "Installed" && !opInProgress
    }

    Column {
        width: parent.width
        spacing: 5
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeHelp
            text: qsTr("Current operation")
        }
        Text {
            id: operationText
            anchors.horizontalCenter: parent.horizontalCenter
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeHelp
            visible: operationText.text.length > 0
        }
        Text {
            id: operationTextApp
            anchors.horizontalCenter: parent.horizontalCenter
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeHelp
            visible: operationTextApp.text.length > 0
        }
        ProgressBar {
            id: progressBar
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width/3*2
            minimumValue: 0
            maximumValue: 100
            value: 50
        }
        visible: opInProgress
    }
    function processOperation(operation, name, version, progress) {
        progressBar.indeterminate = false;
        progressBar.value = progress;
        switch(operation) {
        case 'InstallFile':
        case 'Install':
            operationText.text = qsTr("Installing application");
            operationTextApp.text = "%1 (%2)".arg(name).arg(version);
            break;
        case 'Uninstall':
            operationText.text = qsTr("Unintalling application");
            operationTextApp.text = "%1 (%2)".arg(name).arg(version);
            break;
        case 'Download':
            operationText.text = qsTr("Downloading application");
            operationTextApp.text = "%1 (%2)".arg(name).arg(version);
            break;
        case 'Refresh':
            operationText.text = qsTr("Fetching repositories");
            operationTextApp.text = "";
            progressBar.indeterminate = true;
            break;
        }
    }

    function operationProgress(operation, name, version, progress) {
        //console.log("OPERATION PROGRESS: %1 %2 %3 %4".arg(operation).arg(name).arg(version).arg(progress));
        processOperation(operation, name, version, progress);
    }
    function operationStarted(operation,name,version){
        //console.log("OPERATION STARTED: %1 %2 %3".arg(operation).arg(name).arg(version));
        processOperation(operation,name,version,0)
        opInProgress = true;
    }
    function operationCompleted(operation,name,version,message,error) {
        //console.log("OPERATION COMPLETED: %1 %2 %3 %4 %5".arg(operation).arg(name).arg(version).arg(message).arg(error));
        opInProgress = false;
        updateAppStatus();
    }
    function downloadProgress(operation, name, version, curBytes, totalBytes){
        //console.log("DOWNLOAD PROGRESS: %1 %2 %3 %4 %5".arg(operation).arg(name).arg(version).arg(curBytes).arg(totalBytes));
        operationProgress('Download', name, version, curBytes/totalBytes*100);
    }

    Connections {
        target: pkgManager
        onOperationStarted: operationStarted(operation,name,version)
        onOperationProgress: operationProgress(operation, name, version, progress);
        onOperationCompleted: operationCompleted(operation, name, version, message, error);
        onDownloadProgress: downloadProgress(operation, name, version, curBytes, totalBytes);
        /*
        onPackageListUpdate(QVariant result);
        */
    }
}

