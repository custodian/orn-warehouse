import QtQuick 2.0
import Sailfish.Silica 1.0

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

    headerText: qsTr("Search apps")

    onHeaderClicked: {
        loadedContent.scrollToTop();
    }

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

    content: SilicaListView {
        model: appsModel
        delegate: appDelegate
        clip: true
        cacheBuffer: 400

        header: SearchBox {
            id: searchBox
            width: parent.width
            placeholderText: "Enter keywords"
            onSearchClicked: {
                searchResult.search(searchBox.text);
            }
            onTrashClicked: {
                searchResult.update();
            }
        }

        footer: Item {
            width: parent.width
            height: pagerRow.height + 30
            Row {
                id: pagerRow
                anchors.centerIn: parent
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
        color: myTheme.primaryColor
        font.pixelSize: myTheme.fontSizeMedium
        text: searchResult.busy? qsTr("Searching...") : (__keys.length) ? qsTr("No results found") : qsTr("Enter keywords to search");
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        visible: appsModel.count == 0
    }


    /*Column {
        width: parent.width
        spacing: myTheme.paddingMedium
        anchors {
            bottom: searchResult.bottom
            bottomMargin: myTheme.paddingLarge
        }
        visible: appsModel.count == 0 // && !Qt.inputMethod.visible

        SectionHeader{
            text: qsTr("Browse applications")
        }
        NextBox {
            text: qsTr("by category")
            onAreaClicked: pageStack.push(Qt.resolvedUrl("Categories.qml"))
        }
        NextBox {
            text: qsTr("by publisher")
            onAreaClicked: pageStack.push(Qt.resolvedUrl("Publishers.qml"))
        }
    }
    */
}
