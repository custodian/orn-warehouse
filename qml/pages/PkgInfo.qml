import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: root
    signal uninstall(string name)

    property Item parentPage: undefined
    property bool warehouse: false
    property variant pkg: {}
    property string pkgName: pkg.DisplayName ? pkg.DisplayName.length > 0 ? pkg.DisplayName : pkg.Name : ""

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Package details")
    headerIcon: "image://theme/icon-m-toolbar-application-selected"

    function load() {
        var page = root;
        page.uninstall.connect(function(name){
            pkgManagerProxy.uninstall(name, function(result) {
                page.parentPage.update();
            });
            stack.pop();
        })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: {
                stack.pop()
            }
        }
    }

    QueryDialog  {
        id: uninstallDialog
        icon: "image://theme/icon-m-bootloader-warning"
        titleText: qsTr("Uninstall application")
        message: qsTr("'%1' application was not installed by Warehouse.<br>Are you sure you want uninstall '%2'?").arg(pkgName).arg(pkgName);
        acceptButtonText: qsTr("Yes, uninstall!")
        rejectButtonText: qsTr("No, thanks")
        onAccepted: {
            uninstall(pkg.Name);
        }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            id: packageColumn
            width: parent.width
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            PackageBox {
                application: pkg
                onlyName: true
                width: parent.width

            }

            Text {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 20
                }

                font.pixelSize: mytheme.font.sizeDefault
                wrapMode: Text.Wrap
                text: pkg.Description
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Uninstall")
                onClicked: {
                    if (warehouse) {
                        uninstall(pkg.Name);
                    } else {
                        uninstallDialog.open();
                    }
                }
            }

            Column {
                anchors {
                    left: parent.left
                    leftMargin: 20
                }
                width: 150 //parent.width
                spacing: 10
                Text {
                    width: parent.width
                    font.pixelSize: mytheme.font.sizeSigns
                    wrapMode: Text.Wrap
                    text: qsTr("Version:")
                    Text {
                        anchors.left: parent.right
                        font.pixelSize: mytheme.font.sizeSigns
                        wrapMode: Text.Wrap
                        text: pkg.Version
                    }
                }
                Text {
                    width: parent.width
                    font.pixelSize: mytheme.font.sizeSigns
                    wrapMode: Text.Wrap
                    text: qsTr("Size:")
                    Text {
                        anchors.left: parent.right
                        font.pixelSize: mytheme.font.sizeSigns
                        wrapMode: Text.Wrap
                        text: pkg.InstalledSize
                    }
                }
                Text {
                    width: parent.width
                    font.pixelSize: mytheme.font.sizeSigns
                    wrapMode: Text.Wrap
                    text: qsTr("Installed:")
                    Text {
                        anchors.left: parent.right
                        font.pixelSize: mytheme.font.sizeSigns
                        wrapMode: Text.Wrap
                        text: pkg.InstalledTimestamp
                    }
                }
                Text {
                    width: parent.width
                    font.pixelSize: mytheme.font.sizeSigns
                    wrapMode: Text.Wrap
                    text: qsTr("Source:")
                    Text {
                        anchors.left: parent.right
                        font.pixelSize: mytheme.font.sizeSigns
                        wrapMode: Text.Wrap
                        text: warehouse ? "/net.openrepos.harmattan" : pkg.Origin
                    }
                    visible: pkg.Origin && pkg.Origin.length > 0
                }
            }
        }
    }

}
