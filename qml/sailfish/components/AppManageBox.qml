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
    property bool isRepositoryOutdated: false
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

    function version_compare (v1, v2, operator) {
      // From: http://phpjs.org/functions
      // +      original by: Philippe Jausions (http://pear.php.net/user/jausions)
      // +      original by: Aidan Lister (http://aidanlister.com/)
      // + reimplemented by: Kankrelune (http://www.webfaktory.info/)
      // +      improved by: Brett Zamir (http://brett-zamir.me)
      // +      improved by: Scott Baker
      // +      improved by: Theriault
      // *        example 1: version_compare('8.2.5rc', '8.2.5a');
      // *        returns 1: 1
      // *        example 2: version_compare('8.2.50', '8.2.52', '<');
      // *        returns 2: true
      // *        example 3: version_compare('5.3.0-dev', '5.3.0');
      // *        returns 3: -1
      // *        example 4: version_compare('4.1.0.52','4.01.0.51');
      // *        returns 4: 1
      // BEGIN REDUNDANT
      this.php_js = this.php_js || {};
      this.php_js.ENV = this.php_js.ENV || {};
      // END REDUNDANT
      // Important: compare must be initialized at 0.
      var i = 0,
        x = 0,
        compare = 0,
        // vm maps textual PHP versions to negatives so they're less than 0.
        // PHP currently defines these as CASE-SENSITIVE. It is important to
        // leave these as negatives so that they can come before numerical versions
        // and as if no letters were there to begin with.
        // (1alpha is < 1 and < 1.1 but > 1dev1)
        // If a non-numerical value can't be mapped to this table, it receives
        // -7 as its value.
        vm = {
          'dev': -6,
          'alpha': -5,
          'a': -5,
          'beta': -4,
          'b': -4,
          'RC': -3,
          'rc': -3,
          '#': -2,
          'p': 1,
          'pl': 1
        },
        // This function will be called to prepare each version argument.
        // It replaces every _, -, and + with a dot.
        // It surrounds any nonsequence of numbers/dots with dots.
        // It replaces sequences of dots with a single dot.
        //    version_compare('4..0', '4.0') == 0
        // Important: A string of 0 length needs to be converted into a value
        // even less than an unexisting value in vm (-7), hence [-8].
        // It's also important to not strip spaces because of this.
        //   version_compare('', ' ') == 1
        prepVersion = function (v) {
          v = ('' + v).replace(/[_\-+]/g, '.');
          v = v.replace(/([^.\d]+)/g, '.$1.').replace(/\.{2,}/g, '.');
          return (!v.length ? [-8] : v.split('.'));
        },
        // This converts a version component to a number.
        // Empty component becomes 0.
        // Non-numerical component becomes a negative number.
        // Numerical component becomes itself as an integer.
        numVersion = function (v) {
          return !v ? 0 : (isNaN(v) ? vm[v] || -7 : parseInt(v, 10));
        };
      v1 = prepVersion(v1);
      v2 = prepVersion(v2);
      x = Math.max(v1.length, v2.length);
      for (i = 0; i < x; i++) {
        if (v1[i] == v2[i]) {
          continue;
        }
        v1[i] = numVersion(v1[i]);
        v2[i] = numVersion(v2[i]);
        if (v1[i] < v2[i]) {
          compare = -1;
          break;
        } else if (v1[i] > v2[i]) {
          compare = 1;
          break;
        }
      }
      if (!operator) {
        return compare;
      }

      // Important: operator is CASE-SENSITIVE.
      // "No operator" seems to be treated as "<."
      // Any other values seem to make the function return null.
      switch (operator) {
      case '>':
      case 'gt':
        return (compare > 0);
      case '>=':
      case 'ge':
        return (compare >= 0);
      case '<=':
      case 'le':
        return (compare <= 0);
      case '==':
      case '=':
      case 'eq':
        return (compare === 0);
      case '<>':
      case '!=':
      case 'ne':
        return (compare !== 0);
      case '':
      case '<':
      case 'lt':
        return (compare < 0);
      default:
        return null;
      }
    }

    onAppPackageChanged: {
        console.log("APP PACKAGE:", JSON.stringify(appPackage));
        if (appPackage !== undefined) {
            updateAppStatus();
        }
    }

    function resetState() {
        appInstalled = undefined;
        appAvailable = undefined;
        isUpdateAvailable = false;
        isRepositoryOutdated = false;
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
                //Check for packagename match
                if (appPackage.name == pkgobject.name) {
                    if (pkgobject.data === "openrepos-"+repositoryName) {
                        switch(pkgstatus) {
                        case "available":
                            if (appAvailable === undefined || version_compare(appAvailable.version, pkgobject.version, '<')) {
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
        }
        onTransactionFinished: {
            switch(trname) {
            case packageStateTransaction:
                if (isInstalled && appAvailable !== undefined) {
                    if (version_compare(appAvailable.version, appInstalled.version, '>')) {
                        isUpdateAvailable = true;
                    }
                }
                if (!isInstalled && appAvailable !== undefined) {
                    downloadSizeTransaction = pkgManagerProxy.packageDetails(appAvailable.packageid);
                }
                /*
                //Not all packages send version
                if (appInstalled === undefined || version_compare(appPackage.version, appInstalled.version, '>')) {
                    isRepositoryOutdated = true;
                }
                */
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
                remorse.execute(qsTr("Enabling repository %1").arg(appPackage.name), function(){
                    isStateKnown = false;
                    pkgManagerProxy.enableRepository(repositoryName);
                });
            }
            visible: !isRepositoryEnabled && isStateKnown
        }
        Column {
            width: parent.width

            visible: isStateKnown && !isInProgress

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Check for updates")
                onClicked: {
                    remorse.execute(qsTr("Checking for updates %1").arg(appPackage.name), function(){
                        pkgManagerProxy.refreshSingleRepositoryInfo(repositoryName);
                    });
                }
                visible: isRepositoryEnabled && !isUpdateAvailable /*&& isRepositoryOutdated*/
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Install")
                onClicked: {
                    remorse.execute(qsTr("Installing %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.installPackage(appAvailable.packageid);
                    });
                }
                visible: isRepositoryEnabled && !isInstalled
            }
            /*Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Re-Install")
                onClicked: {
                    remorse.execute(qsTr("Re-Installing %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.installPackage(appAvailable.packageid);
                    });
                }
                visible: isInstalledFromOther && isUpdateAvailable
            }*/
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Upgrade")
                onClicked: {
                    remorse.execute(qsTr("Upgrade %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.updatePackage(appAvailable.packageid);
                    });
                }
                visible: /*isInstalledFromThis && */isUpdateAvailable
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Uninstall")
                onClicked: {
                    remorse.execute(qsTr("Uninstall %1").arg(appPackage.name), function(){
                        packageActionTransaction = pkgManagerProxy.removePackage(appInstalled.packageid);
                    });
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
