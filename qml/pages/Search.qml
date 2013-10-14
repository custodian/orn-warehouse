import Qt 4.7
import com.nokia.meego 1.0
import "../components"
import "../js/api.js" as Api

PageWrapper {
    id: searchResult

    signal application(variant app)
    signal search(string keys)
    signal update()

    property alias appsModel: appsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Search")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = searchResult;
        page.update.connect(function(){
            appsModel.clear();
        });
        page.search.connect(function(keys){
            Api.search.apps(page, keys);
        })
        page.application.connect(function(app) {
            stack.push(Qt.resolvedUrl("Application.qml"),{"application":app});
        });
        page.update();
    }

    function updateView() {
        update();
    }

    ListModel {
        id: appsModel
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
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

        header: Item {
            height: headerColumn.height + 15
            width: parent.width
            Rectangle {
                anchors.fill: parent
                color: mytheme.colors.backgroundSplash
            }
            Column {
                id: headerColumn
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: 10
                }
                spacing: 4
                SearchBox {
                    id: searchBox
                    placeHolderText: "Enter keywords"
                    onSearchClicked: {
                        searchResult.search(searchBox.searchText);
                    }
                    onTrashClicked: {
                        searchResult.update();
                    }
                }
            }
        }
    }

    Component {
        id: appDelegate

        ApplicationBox {
            id: appbox
            application: model.application

            onAreaClicked: {
                searchResult.application( model.application );
            }
        }
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: mytheme.font.sizeSigns
        text: searchResult.busy? qsTr("Searching...") : qsTr("No results found");
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        visible: appsModel.count == 0
    }
}
