import QtQuick 1.1
import com.nokia.meego 1.0

import "."

Column {
    signal busyStatusChanged

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
        text: qsTr("Working");
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
    visible: pkgManagerProxy.opInProgress

    Component.onCompleted: {
        pkgManagerProxy.reemitOperation(processOperation);
    }
    function processOperation(operation){
        progressBar.indeterminate = false;
        progressBar.value = operation.progress;
        switch(operation.operation) {
        case 'InstallFile':
        case 'Install':
            operationText.text = qsTr("Installing application");
            operationTextApp.text = "%1 (%2)".arg(operation.name).arg(operation.version);
            break;
        case 'Upgrade':
            operationText.text = qsTr("Upgrading application");
            operationTextApp.text = "%1 (%2)".arg(operation.name).arg(operation.version);
            break;
        case 'Uninstall':
            operationText.text = qsTr("Uninstalling application");
            operationTextApp.text = "%1 (%2)".arg(operation.name).arg(operation.version);
            break;
        case 'Download':
            operationText.text = qsTr("Downloading application");
            operationTextApp.text = "%1 (%2)".arg(operation.name).arg(operation.version);
            break;
        case 'Refresh':
            operationText.text = qsTr("Fetching repositories");
            operationTextApp.text = "";
            progressBar.indeterminate = true;
            break;
        }
        if (operation.status === "Completed") {
            operationText.text = qsTr("Working");
            operationTextApp.text = "";
        }
    }

    Connections {
        target: pkgManagerProxy
        onProcessedOperation: processOperation(operation)
        onLocalOperationChanged: busyStatusChanged
    }
}
