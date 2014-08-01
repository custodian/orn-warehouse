import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: root
    signal update()

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Installed applications")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = root;
        page.update.connect(function(){
            page.waiting_show();
            pkgManagerProxy.getInstalledPackages(false, function(packages) {
                page.waiting_hide();
                packages.forEach(function(pkg) {
                    var application = { "application" : pkg };
                    appsModel.append(application);
                });
            });
        })
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListModel {
        id: appsModel
    }

    ListView {
        model: appsModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: appDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400
    }

    Component {
        id: appDelegate

        PackageBox {
            application: model.application

            onAreaClicked: {
                stack.push(Qt.resolvedUrl("PkgInfo.qml"), {"pkg" : model.application, "warehouse": false, "parentPage": root});
            }
        }
    }
}
