import Qt 4.7

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
            color: mytheme.colors.textColorShout
            font.pixelSize: mytheme.font.sizeNote
            text: qsTr("not rated yet")
        }
    }
}
