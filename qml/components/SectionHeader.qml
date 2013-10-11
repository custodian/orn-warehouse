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

Item {
    id: root

    property string text: ""

    implicitWidth: parent.width;
    implicitHeight: text.text.length ? text.height : 1

    Rectangle {
        id: line
        anchors {
            left: parent.left
            right: text.text.length ? text.left : parent.right;
            rightMargin: text.text.length ? mytheme.paddingXLarge : 0
            verticalCenter: parent.verticalCenter
        }
        color: mytheme.colors.textColorTimestamp
        height: 1
    }

    Text {
        id: text
        anchors { right: parent.right; rightMargin: mytheme.paddingXLarge }
        color: mytheme.colors.textColorTimestamp
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        font.pixelSize: mytheme.fontSizeXSmall
        font.bold: true
        text: root.text
    }
}
