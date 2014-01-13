import Qt 4.7
import com.nokia.meego 1.0

TabButton {
    id: root
    property string platformIconId
    iconSource: handleIconSource(platformIconId)

    function handleIconSource(iconId) {
        /*if (iconSource != "")
            return iconSource;*/

        var prefix = "icon-m-"
        var inverse = "-white";
        if (iconId.indexOf("toolbar") === -1)
            inverse = "-inverse";
        if (iconId.indexOf(prefix) !== 0)
            iconId =  prefix.concat(iconId).concat(theme.inverted ? inverse : "");
        return "image://theme/" + iconId;
    }

}
