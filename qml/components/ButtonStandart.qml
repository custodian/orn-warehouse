import Qt 4.7
import com.nokia.meego 1.0

Button {
    id: realButton
    width: 100
    height: 50

    property string label: "-"
    property string prefix: ""
    property string suffix: ""

    text: label

    platformStyle: ButtonStyle {

        textColor: "#ffffff"
        pressedTextColor: "#ffffff"
        disabledTextColor: "#ffffff"
        checkedTextColor: "#ffffff"

        background: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix?"-"+suffix:"")+(position?"-"+position:"")
        checkedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix!=""?"-"+suffix:"")+((suffix!="")?"":"-selected")+(position?"-"+position:"")
        pressedBackground: "image://theme/meegotouch-button"+((prefix!="" && !theme.inverted)?"-"+prefix:"")+__invertedString+"-background"+(suffix!=""?"-"+suffix:"")+((suffix!="")?"":"-pressed")+(position?"-"+position:"")
    }

}
