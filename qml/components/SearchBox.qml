import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property alias searchText: searchTextInput.text
    property alias placeHolderText: searchTextInput.placeholderText
    property alias maximumLength: searchTextInput.maximumLength

    signal searchClicked
    signal trashClicked

    width: parent ? parent.width : 0
    height: searchTextInput.height

    onSearchClicked: {
        searchTextInput.platformCloseSoftwareInputPanel();
        dummy.focus = true
    }

    Item { id: dummy }

    FocusScope {
        id: textPanel

        anchors.left: parent.left
        anchors.right: searchButton.left
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height

        SipAttributes {
            id: sipAttributes
            actionKeyLabel: /*translatorItem.emptyString +*/ qsTr("Search")
            //actionKeyHighlighted: true
            actionKeyEnabled: searchTextInput.text.length > 0

        }

        TextField {
            id: searchTextInput

            clip: true
            inputMethodHints: Qt.ImhNoPredictiveText
            platformSipAttributes: sipAttributes
            anchors {
                left: parent.left
                right: parent.right
                rightMargin: -searchButton.width - searchButton.anchors.rightMargin
                verticalCenter: textPanel.verticalCenter
            }
            platformStyle: TextFieldStyle {
                paddingRight: clearTextButton.width + 10 + searchButton.width + searchButton.anchors.rightMargin
            }
            onActiveFocusChanged: {
                if (!searchTextInput.activeFocus) {
                    searchTextInput.platformCloseSoftwareInputPanel()
                }
            }
            Keys.onReturnPressed: root.searchClicked()
        }
    }
    Button {
        id: clearTextButton
        iconSource: "image://theme/icon-m-toolbar-delete"//"trash.png"
        anchors {
            right: searchButton.left
            rightMargin: -1
            verticalCenter: parent.verticalCenter
        }
        height: searchButton.height
        width: searchButton.width
        visible: searchTextInput.text.length > 0
        onClicked: {
            searchTextInput.text = ""
            searchTextInput.forceActiveFocus()
            root.trashClicked()
        }
    }
    Button {
        id: searchButton
        iconSource: enabled ? "image://theme/icon-m-toolbar-search" : "image://theme/icon-m-toolbar-search-white"
        anchors {
            right: parent.right
            rightMargin: 3
            verticalCenter: parent.verticalCenter
        }
        height: root.height - anchors.rightMargin
        width: height*1.5
        enabled: searchTextInput.text.length > 0
        onClicked: {
            root.searchClicked()
        }
    }
}
