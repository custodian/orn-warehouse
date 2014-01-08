import QtQuick 2.0
import Sailfish.Silica 1.0

PageWrapper {
    id: errorDialog

    property string trName: ""
    property string trStatus: ""
    property string trMessage: ""

    width: parent.width
    height: Theme.itemSizeExtraLarge + Theme.paddingLarge + errorColumn.height

    headerText: qsTr("Error occured")

    content: Column {
        anchors {
            left: parent.left
            right: parent.right
            margins: myTheme.paddingMedium
        }
        spacing: 5

        Text {
            text: qsTr("Transaction %1").arg(trName)
            color: myTheme.highlightColor
            font.pixelSize: myTheme.fontSizeSmall
        }
        Text {
            text: qsTr("Status: %1").arg(trStatus)
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
        }
        Text {
            text: qsTr("Extra details:")
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
        }
        Text {
            width: parent.width
            color: myTheme.primaryColor
            font.pixelSize: myTheme.fontSizeSmall
            wrapMode: Text.WordWrap
            text: trMessage
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Dismiss")
            onClicked: stack.pop();
        }
    }
}
