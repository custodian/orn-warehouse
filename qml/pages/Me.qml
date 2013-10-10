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

    headerText: qsTr("Me or Developers")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        /*page.update.connect(function(){
            Api.apps.loadRecent(page);
        })*/
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    ListView {
        //model: appsModel
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        delegate: catDelegate
        //highlightFollowsCurrentItem: true
        clip: true
        cacheBuffer: 400

        //header:
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: mytheme.font.sizeSigns
        text: "This is not implemented yet, come back later!"
        width: parent.width
        horizontalAlignment: Text.AlignHCente
        wrapMode: Text.WordWrap
    }

    Component {
        id: catDelegate

        Item{}
    }
}
