import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appList
    signal update()


    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Installed applications")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        page.update.connect(function(){
            page.waiting_show();
            pkgManagerProxy.getInstalledPackages(function(packages) {
                page.waiting_hide();
                packages.forEach(function(pkg) {
                    var application = { "application" :{
                                         "title": pkg.DisplayName,
                                         "icon": {
                                            "url": "base64://" + pkg.IconData + ".png",
                                         },
                                         "category": [pkg.Category]
                                        }
                                     };
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

        ApplicationBox {
            id: appbox
            categorystyle: "done"
            application: model.application

            onAreaClicked: {
                appList.application( model.application );
            }
        }
    }
}
