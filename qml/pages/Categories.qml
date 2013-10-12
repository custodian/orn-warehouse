import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: catList
    signal update()

    property variant categories: []


    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Categories")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = catList;
        page.update.connect(function(){
            Api.categories.loadCategories(page);
        });
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
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
            width: parent.width
            spacing: 5

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            Repeater {
                width: parent.width
                model: catList.categories
                delegate: catMainDelegate
            }
        }
    }

    Component {
        id: catMainDelegate

        Column {
            width: parent.width
            NextBox {
                text: "%1 (%2)".arg(modelData.name).arg(modelData.apps_count)
            }
            Column {
                anchors {
                    left: parent.left
                    leftMargin: 50
                    right: parent.right
                }
                Repeater {
                    model: modelData.childrens
                    width: parent.width
                    delegate: NextBox {
                        text: "%1 (%2)".arg(modelData.name).arg(modelData.apps_count)
                    }
                }
            }
        }
    }
}
