import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

PageWrapper {
    id: availableUpdates
    signal update()

    property string getUpdatesTransaction: ""
    property string makeUpdateTransaction: ""
    property string updatedApplication: ""

    width: parent.width
    height: parent.height

    headerText: qsTr("Updates")

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

    function load() {
        var page = availableUpdates;
        page.update.connect(function(){
            page.waiting_show();
            updateModel.clear();
            getUpdatesTransaction = pkgManagerProxy.getUpdatesList();
        });
        page.update();
    }

    ListModel {
        id: updateModel
    }

    Connections {
        target: pkgManagerProxy

        onTransactionPackage: {
            if (trname == getUpdatesTransaction) {
                var repository = pkgobject.data;
                //Skip non openrepos updates
                if (repository && repository.indexOf("openrepos") != -1) {
                    updateModel.append({"application":pkgobject});
                }
            }
        }

        onTransactionFinished: {
            switch(trname) {
            case getUpdatesTransaction:
                availableUpdates.waiting_hide();
                getUpdatesTransaction = "";
                break;
            case makeUpdateTransaction:
                if (updatedApplication == "harbour-warehouse") {
                    remorseUpdate.execute("Restarting warehouse", function() {
                        Qt.quit();
                    });
                }
                makeUpdateTransaction = "";

                updatedApplication = "";
                availableUpdates.update();
                break;
            }
        }

    }

    content: SilicaListView {
        id: updatesView
        model: updateModel
        delegate: updateDelegate
        clip: true

        header: Column {
            width: parent.width
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Check for updates")
                onClicked: {
                    pkgManagerProxy.refreshRepositoryInfo();
                    updatesView.scrollToTop();
                }
            }
            SectionHeader {
                text: qsTr("Current operation")
            }
            PkgManagerStatus {
                id: pkgStatus
                showPending: false
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                text: qsTr("Queue is empty")
                visible: !pkgStatus.transactionCount
            }
            SectionHeader {
                text: qsTr("Available updates")
            }
        }
    }

    RemorsePopup {
        id: remorseUpdate
    }

    Component {
        id: updateDelegate

        PackageBox {
            application: model.application

            onAreaClicked: {
                remorseUpdate.execute("Updating %1".arg(application.name), function() {
                    updatedApplication = application.name;
                    makeUpdateTransaction = pkgManagerProxy.installPackage(application.packageid);
                });
            }
        }
    }
}
