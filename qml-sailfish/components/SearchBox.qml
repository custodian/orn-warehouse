import QtQuick 2.0
import Sailfish.Silica 1.0

TextField {
    id: searchField

    signal searchClicked
    signal trashClicked

    implicitWidth: _editor.implicitWidth + Theme.paddingSmall
                   + Theme.itemSizeSmall*2  // width of two icons
    height: Math.max(Theme.itemSizeMedium, _editor.height + Theme.paddingMedium + Theme.paddingSmall)

    focusOutBehavior: FocusBehavior.ClearPageFocus
    font {
        pixelSize: Theme.fontSizeLarge
        family: Theme.fontFamilyHeading
    }

    textLeftMargin: Theme.itemSizeSmall + Theme.paddingMedium
    textRightMargin: Theme.itemSizeSmall + Theme.paddingMedium
    textTopMargin: height/2 - _editor.implicitHeight/2
    labelVisible: false

    //: Placeholder text of SearchField
    //% "Search"
    placeholderText: qsTrId("components-ph-search")
    onFocusChanged: if (focus) cursorPosition = text.length

    inputMethodHints: Qt.ImhNoPredictiveText

    Keys.onReturnPressed: searchField.searchClicked()

    background: Component {
        Item {
            anchors.fill: parent

            IconButton {
                x: searchField.textLeftMargin - width - Theme.paddingSmall
                width: icon.width
                height: parent.height
                icon.source: "image://theme/icon-m-search"
                highlighted: down || searchField._editor.activeFocus

                enabled: searchField.enabled

                onClicked: {
                    searchField._editor.forceActiveFocus()
                    searchClicked()
                }
            }

            IconButton {
                id: clearButton
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                width: icon.width
                height: parent.height
                icon.source: "image://theme/icon-m-clear"

                enabled: searchField.enabled

                opacity: searchField.text.length > 0 ? 1 : 0
                Behavior on opacity {
                    FadeAnimation {}
                }

                onClicked: {
                    searchField.text = ""
                    searchField._editor.forceActiveFocus()
                    trashClicked()
                }
            }
        }
    }
}
