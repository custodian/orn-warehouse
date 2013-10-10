/*
    Copyright (C) 2012 Dickson Leong
    This file is part of Tweetian.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Item{
    id: root

    property url headerIcon: ""
    property string headerText: ""

//    property string headerSelectionTitle: ""
//    property alias headerSelectionItems: headerSeletionDialog.model

    property bool busy: false
    property bool countBubbleVisible: true
    property int countBubbleValue: appWindow.notificationsCount

    signal selectedItem(int index)

    implicitHeight: mytheme.headerHeight
    anchors { top: parent.top; left: parent.left; right: parent.right }

/*    SelectionDialog {
        id: headerSeletionDialog
        titleText: headerSelectionTitle
        onSelectedIndexChanged: {
            root.selectedItem(selectedIndex);
        }

        model: ListModel {}
    }
*/
    Image {
        id: background
        anchors.fill: parent
        //was color 7
        //source: "image://theme/color9-meegotouch-view-header-fixed" + (mouseArea.pressed ? "-pressed" : "")
        //source: "image://theme/color9-meegotouch-view-header-fixed-pressed"
        source: "image://theme/color9-meegotouch-view-header-fixed"
    }

    CacheImage{
        id: icon
        sourceUncached: headerIcon
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; margins: mytheme.paddingXXLarge }
        height: sourceSize.height; width: sourceSize.width
    }

    Text{
        id: mainText
        anchors{
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: busyIndicatorLoader.status === Loader.Ready ? busyIndicatorLoader.left : parent.right
            margins: mytheme.paddingXXLarge
        }
        elide: Text.ElideRight
        font.pixelSize: mytheme.fontSizeLarge
        color: "white"
        text: headerText
    }

    Loader{
        id: busyIndicatorLoader
        anchors{ right: parent.right; rightMargin: mytheme.paddingXXLarge; verticalCenter: parent.verticalCenter }
        sourceComponent: busy ? busyIndicatorComponent : (countBubbleVisible ? countBubbleComponent : undefined)
    }

    Component{
        id: busyIndicatorComponent

        BusyIndicator{
            running: true
            Component.onCompleted: {
                platformStyle.inverted = true
            }
        }
    }

    Component{
        id: countBubbleComponent

        CountBubble{
            value: root.countBubbleValue
            largeSized: true
            visible: value!==0
        }
    }

/*    MouseArea{
        id: mouseArea
        anchors.fill: mainText
        enabled: headerSelectionItems.count
        onClicked: {
            headerSeletionDialog.open();
        }
    }
*/

    MouseArea {
        id: mouseAreaBubble
        anchors.fill: busyIndicatorLoader
        enabled: countBubbleVisible
        onClicked: {
            processUINotification(0);
        }
    }
}
