import Qt 4.7

Row {
    id: scorebox
    property int score: 60+Math.random()*40

    spacing: 4

    Repeater {
        model: 5
        delegate: Image {
            source: (score/20 >= index)?"../images/star_active.png":"../images/star_inactive.png"
        }
    }
}
