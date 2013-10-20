import Qt 4.7
import com.nokia.meego 1.0
import "../build.info.js" as BuildInfo
import "../components"

//TODO: dont forget about PAGESTACK:

PageWrapper {
    signal authDeleted()

    signal settingsChanged(string type, string value);

    property string cacheSize: qsTr("updating...")

    id: settings
    color: mytheme.colors.backgroundMain

    width: parent.width
    height: parent.height

    headerText: qsTr("SETTINGS")
    headerIcon: "image://theme/icon-m-toolbar-settings-selected" //"../icons/icon-header-settings.png"
    headerBubble: false

    tools: ToolBarLayout{
        ToolIcon{
            platformIconId: "toolbar-back"
            onClicked: {
                stack.pop()
            }
        }

        ToolIcon {
            platformIconId: "icon-m-invitation-pending"//"icon-m-user-guide"
            onClicked: {
                infoDialog.open();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: {
                menu.open();
            }
        }
    }

    QueryDialog  {
        id: infoDialog

        icon: "../images/openrepos_beta.png"//"image://theme/icon-m-user-guide"
        titleText: "Warehouse"
        message: ("%1\n%2\n\n%6: %7\n%8: %9\n\n%10")
        .arg("2013 Basil Semuonov")
        .arg(qsTr("If any problems, tweet @basil_s"))
        .arg(qsTr("Version"))
        .arg(BuildInfo.version)
        .arg(qsTr("Build"))
        .arg(BuildInfo.build)
        .arg("Powered by OpenRepos")

        rejectButtonText: qsTr("Close")
    }

    QueryDialog  {
        id: eraseSettingsDialog
        icon: "image://theme/icon-l-accounts"
        titleText: qsTr("Reset settings")
        message: qsTr("This action will erase all data including auth token, application settings and cache.")
        acceptButtonText: qsTr("Yes, clear the data")
        rejectButtonText: qsTr("No, thanks")
        onAccepted: {
            configuration.resetSettings();
        }
    }

    SelectionDialog {
        id: translationSelector
        titleText: qsTr("Language")
        onAccepted: {
            settingsChanged("language",languageNamesModel.get(selectedIndex).code);
        }
    }

    ListModel {
        id: languageNamesModel

        Component.onCompleted: {
            var langs = appTranslator.getAvailableLanguages()
            for(var lang in langs) {
                languageNamesModel.append({"name":langs[lang],"code":lang});
            }
            translationSelector.model = languageNamesModel;
            /*for (var i=0; i<internal.languagesCodesArray.length; i++) {
                if (internal.languagesCodesArray[i] === settings.translateLangCode) {
                    selectedIndex = i
                    break
                }
            }*/
        }
    }

    Menu {
        id: menu
        MenuLayout {
            MenuItem {
                text: qsTr("Check updates")
                onClicked: {
                    updateDialog.getupdates();
                }
            }
            MenuItem {
                text: qsTr("Reset settings")
                onClicked: {
                    eraseSettingsDialog.open();
                }
            }
        }
    }

    function load() {
        var page = settings;
        page.authDeleted.connect(function(){
            configuration.settingChanged("accessToken","");
        });
        page.settingsChanged.connect(function(type,value) {
            configuration.settingChanged(type,value);
        });
        cacheUpdater.start();
    }

    Timer {
        id: cacheUpdater
        interval: 2000
        repeat: false
        onTriggered: {
            cacheSize = imageCache.info();
        }
    }

    TabGroup {
        id: settingTabGroup
        anchors { left: parent.left; right: parent.right; top: tabButttonRow.bottom; bottom: parent.bottom }
        currentTab: generalTab

        Flickable {
            id: generalTab

            anchors.fill: parent
            contentHeight: generalTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: generalTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                //Check updates
                SectionHeader{
                    text: qsTr("UPDATES CHECK")
                }
                ButtonRow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    //width: parent.width
                    onVisibleChanged: {
                        if (visible) {
                            switch(configuration.updateType) {
                            case "none":
                                checkedButton = btnUpdateNone;
                                break;
                            case "stable":
                                checkedButton = btnUpdateStable;
                                break;
                            case "beta":
                                checkedButton = btnUpdateBeta;
                                break;
                            case "alpha":
                                checkedButton = btnUpdateAlpha;
                                break;
                            }
                        }
                    }
                    Button{
                        id: btnUpdateNone
                        text: qsTr("None")
                        onClicked: settingsChanged("updateType","none")
                    }

                    Button{
                        id: btnUpdateStable
                        text: qsTr("Stable")
                        onClicked: settingsChanged("updateType","stable")
                    }
                    Button{
                        id: btnUpdateBeta
                        text: qsTr("Beta")
                        onClicked: settingsChanged("updateType","beta")
                    }

                    Button{
                        id: btnUpdateAlpha
                        text: qsTr("Alpha")
                        onClicked: settingsChanged("updateType","alpha")
                    }
                }

                SectionHeader {}
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "https://openrepos.net/content/basil/warehouse"
                    color: mytheme.colors.textColorOptions
                    font.pixelSize: mytheme.font.sizeHelp
                    font.underline: true

                    horizontalAlignment: Text.AlignHCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            Qt.openUrlExternally("https://openrepos.net/content/basil/warehouse");
                        }
                    }
                }
                Item{
                    height: 20
                    width: parent.width
                }

            }
        }
        Flickable {
            id: themeTab

            anchors.fill: parent
            contentHeight: themeTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: themeTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader{
                    text: qsTr("LANGUAGE")
                }
                Button{
                    text: appTranslator.getLanguageName(configuration.language) //"Default"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        translationSelector.open();
                    }
                }
            }
        }
        Flickable {
            id: serviceTab

            anchors.fill: parent
            contentHeight: serviceTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: serviceTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader{
                    text: qsTr("IMAGE LOADING")
                }
                ButtonRow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    //width: parent.width
                    onVisibleChanged: {
                        if (visible) {
                            switch(configuration.imageLoad) {
                            case "cached":
                                checkedButton = btnImageCache;
                                break;
                            case "all":
                                checkedButton = btnImageAll;
                                break;
                            }
                        }
                    }
                    Button{
                        id: btnImageAll
                        text: qsTr("All")
                        onClicked: settingsChanged("imageLoad","all")
                    }
                    Button{
                        id: btnImageCache
                        text: qsTr("Cached")
                        onClicked: settingsChanged("imageLoad","cached")
                    }
                }

                SectionHeader{
                    text: qsTr("APPLICATION CACHE")
                }
                Item {
                    width: parent.width
                    height: btnCacheClear.height

                    Text {
                        id: textSize
                        color: mytheme.colors.textColorOptions
                        font.pixelSize: mytheme.font.sizeSigns
                        font.bold: true
                        anchors {
                            verticalCenter: btnCacheClear.verticalCenter
                            left: parent.left
                            right: btnCacheClear.right
                            margins: 10
                        }
                        height: 35
                        text: qsTr("Size: %1").arg(cacheSize);
                    }

                    Button {
                        id: btnCacheClear
                        anchors {
                            right: parent.right
                            rightMargin: 10
                        }

                        text: qsTr("Clear")
                        width: 150
                        onClicked: {
                            imageCache.reset();
                            cacheSize = imageCache.info();
                        }
                    }
                }

                SectionHeader{
                    text: qsTr("UI")
                }
                Button{
                    text: qsTr("Reload UI")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: appWindow.reloadUI()
                }

                SectionHeader {
                    text: qsTr("AUTHENTICATION")
                }
                Button {
                    text: qsTr("Reset authentication")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        authDeleted()
                    }
                }

            }
        }
        Flickable {
            id: debugTab

            anchors.fill: parent
            contentHeight: debugTabColumn.height + 2 * mytheme.paddingMedium

            Column {
                id: debugTabColumn
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: mytheme.paddingMedium }
                spacing: mytheme.paddingMedium

                SectionHeader{
                    text: qsTr("DEBUG")
                }
                SettingSwitch{
                    text: qsTr("Enable debug")
                    checked: configuration.debugEnabled === "1"
                    onCheckedChanged: {
                        var value = (checked)?"1":"0";
                        settingsChanged("debugEnabled",value);
                    }
                }

                Column {
                    width: parent.width
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: mytheme.fontSizeLarge
                        color: mytheme.colors.textColorOptions
                        text: qsTr("Options will be available soon")
                    }
                    visible: configuration.debugEnabled === "1"
                }
            }
        }
    }

    //ScrollDecorator{ flickableItem: settingTabGroup }

    ButtonRow {
        id: tabButttonRow
        anchors { top: pagetop; left: parent.left; right: parent.right }

        TabButton { tab: generalTab; text: qsTr("General")}
        TabButton { tab: themeTab; text: qsTr("Theme") }
        TabButton { tab: serviceTab; text: qsTr("Service") }
        TabButton { tab: debugTab; text: qsTr("Debug") }
    }

}
