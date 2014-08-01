import Qt 4.7
import com.nokia.meego 1.0
import "../components"
import "../js/api.js" as Api

PageWrapper {
    id: searchResult

    signal application(variant app)
    signal search(string keys)
    signal update()

    property int page: 0
    property int pageSize: 10
    property string __keys: ""
    property alias appsModel: appsModel

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Search")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = searchResult;
        page.update.connect(function(){
            page.page = 0;
            page.__keys = "";
            appsModel.clear();
        });
        page.search.connect(function(keys){
            if (keys == "") {
                keys = __keys;
            } else {
                __keys = keys;
            }
            Api.search.apps(page, keys, page.page);
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

        header: Rectangle {
            height: headerColumn.height + 20
            width: parent.width
            color: mytheme.colors.backgroundSplash

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

        footer: Item {
            width: parent.width
            height: pagerRow.height + 30
            ButtonRow {
                id: pagerRow
                anchors.centerIn: parent
                exclusive: false
                Button {
                    //anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Prev page")
                    visible: searchResult.page > 0
                    onClicked: {
                        searchResult.page--;
                        searchResult.search("");
                    }
                }
                Button {
                    //anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Next page")
                    visible: appsModel.count == searchResult.pageSize
                    onClicked: {
                        searchResult.page++;
                        searchResult.search("");
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
