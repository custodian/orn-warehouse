import Qt 4.7
import com.nokia.meego 1.0
import "../js/update.js" as Updater
import "../build.info.js" as BuildInfo

QueryDialog  {
    id: updateDialog
    property string version: ""
    property string build: ""
    property string url: ""
    property string changelog: ""
    property string updatetype: configuration.updateType

    icon: "image://theme/icon-m-content-system-update-dialog"
    titleText: qsTr("New update available")
    message: qsTr("Version: %1<br>Type: %2<br>Build: %3<br><br>Changelog: <br>%4")
        .arg(version)
        .arg(updatetype)
        .arg(build)
        .arg(changelog);

    acceptButtonText: qsTr("Update!")
    rejectButtonText: qsTr("No, thanks")
    onAccepted: {
        Qt.openUrlExternally(url);
        //TODO:
        //windowHelper.disableSwype(false);
        Qt.quit();
    }
    onRejected: {
    }

    Component.onCompleted: {
        updateTimer.start();
    }

    Timer {
        id: updateTimer
        repeat: true
        interval: 600 * 1000
        triggeredOnStart: true
        onTriggered: {
            getupdates();
        }
    }

    function getupdates() {
        if (updatetype!=="none") {
            Updater.getUpdateInfo("meego",updatetype,onUpdateAvailable);
        }
    }
    function onUpdateAvailable(build, version, changelog, url) {
        var update = false;
        if (updatetype == "beta") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (updatetype == "alpha") {
            if (build > BuildInfo.build) {
                update = true;
            }
        } else if (updatetype == "stable") {
            if (version !== BuildInfo.version || build !== BuildInfo.build) {
                update = true;
            }
        }

        if (update){
            console.log("UPDATE IS AVAILABLE: " + build);
            updateDialog.build = build;
            updateDialog.version = version;
            updateDialog.url = url;
            updateDialog.changelog = changelog;
            //if (accessToken.length > 0) {
                updateDialog.open();
            //}
        }
    }
}
