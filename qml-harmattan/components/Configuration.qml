import QtQuick 1.1
import "../js/database.js" as Database

QtObject {
    id: config

    signal settingsLoaded
    signal settingsReseted

    Component.onCompleted: {
        loadSettings();
    }

    function loadSettings() {
        var results = Database.getAllSettings()
        for (var s in results) {
            settingChanged(s, results[s]);
        }
        settingsLoaded()
    }

    function resetSettings() {
        Database.resetSettings();
        updateType = "none"
        imageLoad = "all"
        language = "en"
        debugEnabled = ""

        settingsReseted()
    }

    function settingChanged(name, value) {
        if (config.hasOwnProperty(name)) {
            config[name] = value;
        }
    }

    function save(name) {
        if (config.hasOwnProperty(name)) {
            var data = JSON.parse("{ \"%1\" : \"%2\" }".arg(name).arg(config[name]));
            //console.log("Saved setting: " + JSON.stringify(data));
            Database.setSetting(data);
        }
    }

    property string updateType: "none"
    onUpdateTypeChanged: save("updateType")

    property string language: "en"
    onLanguageChanged: save("language")

    property string debugEnabled: ""
    onDebugEnabledChanged: save("debugEnabled")

    property string imageLoad: "all"
    onImageLoadChanged: save("imageLoad")
}
