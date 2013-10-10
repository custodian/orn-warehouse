import Qt 4.7
import "../components"
import com.nokia.meego 1.0

PageWrapper {
    id: welcomePage
    signal login()
    signal later()

    property bool newuser: false
    headerText: ""

    function load() {
        welcomePage.login.connect(function(){
            //create login Component
            stack.push(Qt.resolvedUrl("Login2openrepos.qml"));
        });
        welcomePage.later.connect(function() {
            //process back to client
        });
    }

    Rectangle {
        anchors.fill: parent
        color: mytheme.colors.backgroundSplash
    }

    Image {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: loginBox.top
            bottomMargin: loginBox.y/3
        }
        source: "../images/openrepos_beta.png"
    }

    Text {
        text: qsTr("Welcome!")
        anchors.centerIn: parent
        color: mytheme.colors.textColorSign
        font.pixelSize: mytheme.font.sizeDefault
        font.family: mytheme.font.name
        visible: !newuser
    }

    Item {
        id: loginBox
        width: parent.width
        anchors.centerIn: parent
        Column{
            width: parent.width
            spacing: 20
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Please, login with OpenRepos!")
                color: mytheme.colors.textColorSign
                font.pixelSize: mytheme.font.sizeDefault
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                id: loginButton
                text: qsTr("Login")
                width: parent.width - 130
                onClicked: {
                    welcomePage.login();
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                id: laterButton
                text: qsTr("Later")
                width: parent.width - 130
                onClicked: {
                    welcomePage.later();
                }
            }

            Item {
                width: parent.width
                height: 50
            }

            /*Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Foursquare privacy policy")
                color: mytheme.colors.textColorSign
                font.underline: true
                font.pixelSize: mytheme.font.sizeDefault
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://foursquare.com/legal/terms")
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Nelisquare privacy policy")
                color: mytheme.colors.textColorSign
                font.underline: true
                font.pixelSize: mytheme.font.sizeDefault
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("http://thecust.net/nelisquare/privacy.txt")
                    }
                }
            }*/
        }

        visible: newuser
    }
}
