import QtQuick 1.1

Item {
    id: lightTheme
    property variant colors
    property bool inverted: false

    Component.onCompleted: {
        colors = {
            "name": "light",

            "textColor": "#111",
            "textColorAlarm": "#d66",

            "notificationBackground": "#18659c",

            "checktapBackground": "#05416d",
            "checktapBackgroundActive": "#555",
            "checktapBorderColor": "#444",

            "toolbarDarkColor": "#17649A",
            "toolbarLightColor": "#40B3DF",

            "waitingInicatorBackGround": "#dcd4ca",

            "textButtonText": "#35a7d9",
            "textButtonTextInactive": "#8e857c",

            "textButtonTextMenu": "#33b5e5",
            "textButtonTextMenuInactive": "gray",

            "textColorSign": "white",
            "textHeader": "white",
            "textPoints": "white",
            "textColorButton": "white",
            "textColorButtonPressed": "white",
            "textColorOptions": "#635959",
            "textColorProfile": "#635959",
            "textColorShout": "#555555",
            "textColorTimestamp": "#918980",

            "blueButtonBorderColor": "#18518c",
            "blueButtonBorderColorPressed": "#2778b3",

            "greenButtonBorderColor": "#7aac00",
            "greenButtonBorderColorPressed": "#7aac00",

            "grayButtonBorderColor": "#999",
            "grayButtonBorderColorPressed": "#666",

            "textboxBorderColor": "#aaa",

            "photoBorderColor": "#ccc",
            "photoBackground": "#fff",

            "backgroundMain": "#E0E1E2",
            "backgroundMenubar": "#404040",
            "backgroundBlueDark": "#176095",
            "backgroundSplash": "#4e4e4e",

            "backgroundSand": "#dcd4ca",

            "scoreBackgroundColor": "#dcd4ca",
            "scoreForegroundColor": "#0072b1",
        };
    }

    function getGradient(type) {
        return lightTheme[type];
    }
}
