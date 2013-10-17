import Qt 4.7
import "../js/api.js" as Api

Item {
    id: pkgManagerProxy
    signal processedOperation(variant operation)

    property variant lastoperation: undefined
    property int actionNumber: 0

    function queueAction(callback) {
        var actionitem = "action-%1-%2".arg(actionNumber++).arg(data);
        var actionitemobj = Api.objs.save(actionitem);
        actionitemobj.callback = callback;
        var msg = {
            "item": actionitem,
        };
        pkgManager.queueAction(msg);
    }

    function processAction(msg) {
        var actionitemobj = Api.objs.get(msg.item);
        actionitemobj.callback();
        Api.objs.remove(msg.item);
    }

    //Direct syncronious function
    function enableRepository() {

    }

    function reemitOperation(callback) {
        if (lastoperation !== undefined) {
            callback(lastoperation);
        }
        queueAction(function(){mycallBack("mvahaha")});
    }

    function mycallBack(arg) {
        console.log("callback: " + arg);
    }

    //##### Callback-signal functions #####
    function processOperation(status, operation, name, version, progress) {
        lastoperation = {
            "status": status,
            "operation": operation,
            "name": name,
            "version": version,
            "progress": progress
        };
        pkgManagerProxy.processedOperation(lastoperation);
    }

    function operationProgress(operation, name, version, progress) {
        //console.log("OPERATION PROGRESS: %1 %2 %3 %4".arg(operation).arg(name).arg(version).arg(progress));
        processOperation("Progress", operation, name, version, progress);
    }
    function operationStarted(operation,name,version){
        //console.log("OPERATION STARTED: %1 %2 %3".arg(operation).arg(name).arg(version));
        processOperation("Started", operation, name, version, 0)
    }
    function operationCompleted(operation,name,version,message,error) {
        //console.log("OPERATION COMPLETED: %1 %2 %3 %4 %5".arg(operation).arg(name).arg(version).arg(message).arg(error));
        processOperation("Completed", operation, name, version, 0)
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

        //onActionDone: actionDone(msg);
        /*
        onPackageListUpdate(QVariant result);
        */
    }
}
