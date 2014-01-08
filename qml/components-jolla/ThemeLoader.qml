import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: themeLoader
    property string name: "light"

    property variant colors
    property bool inverted: false
    onInvertedChanged: {
        theme.inverted = themeLoader.inverted;
    }

    // padding size
    property int paddingSmall: Theme.paddingSmall
    property int paddingMedium: Theme.paddingMedium
    property int paddingLarge: Theme.paddingLarge

    // font size
    property int fontSizeTiny: Theme.fontSizeTiny
    property int fontSizeExtraSmall: Theme.fontSizeExtraSmall
    property int fontSizeSmall: Theme.fontSizeSmall
    property int fontSizeMedium: Theme.fontSizeMedium
    property int fontSizeLarge: Theme.fontSizeLarge
    property int fontSizeExtraLarge: Theme.fontSizeExtraLarge
    property int fontSizeHuge: Theme.fontSizeHuge

    //itemSizes
    property real iconSizeSmall: Theme.iconSizeSmall
    property real iconSizeMedium: Theme.iconSizeMedium
    property real iconSizeLarge: Theme.iconSizeLarge

    //itemSizes
    property real itemSizeSmall: Theme.itemSizeSmall
    property real itemSizeMedium: Theme.itemSizeMedium
    property real itemSizeLarge: Theme.itemSizeLarge
    property real itemSizeExtraLarge: Theme.itemSizeExtraLarge

    property color primaryColor: Theme.primaryColor
    property color secondaryColor: Theme.secondaryColor
    property color highlightColor: Theme.highlightColor
    property color secondaryHighlightColor: Theme.secondaryHighlightColor

/*    function loadTheme(type) {
        //console.log("LOADING THEME " + type)
        //actually loading theme
        var factory = Qt.createComponent(Qt.resolvedUrl("../themes/"+type + ".qml"));
        if (factory.status === Component.Ready) {
            var loadedTheme = factory.createObject(themeLoader);
            applyTheme(loadedTheme);
        } else {
            console.log("Theme " + type + " not found!");
        }
    }
*/
}
