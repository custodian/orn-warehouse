import QtQuick 2.0

Item {
    id: scorebox
    property variant rating: {}
    property int score: rating.rating || 0

    height: loader.height
    width: loader.width

    Loader {
        id: loader
        sourceComponent: rating ? rating.count > 0 ? stars : unrated : undefined
    }
    Component {
        id: stars
        Row {
            spacing: 4
            Repeater {
                model: 5
                delegate: Image {
                    source: (score/20 >= index)?"../images/star_active.png":"../images/star_inactive.png"
                }
            }
        }
    }
    Component {
        id: unrated
        Text {
            color: myTheme.secondaryColor
            font.pixelSize: myTheme.fontSizeExtraSmall
            text: qsTr("not rated yet")
        }
    }
}
