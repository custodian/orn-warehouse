import Qt 4.7
import com.nokia.extras 1.1 //MaskedItem

Item {
    id: profileImage

    signal clicked()

    property string photoUrl: ""
    property int photoSize: 64
    property int photoWidth: photoSize
    property int photoHeight: photoSize
    property int photoBorder: 0
    property bool photoCache: true
    property variant photoSourceSize: undefined
    property bool enableMouseArea: true
    property bool photoSmooth: true
    property variant photoAspect: Image.PreserveAspectCrop

    property bool masked: false

    width: photoWidth
    height: photoHeight

    Loader {
        sourceComponent: (masked ? maskedImage : cachedImage)
    }

    Component {
        id: maskedImage

        MaskedItem {
            width: photoWidth
            height: photoHeight
            mask: Image{
                width: photoWidth
                height: photoHeight
                source: "../images/image_mask.png"
            }

            Loader {
                sourceComponent: cachedImage
            }

        }
    }

    Component {
        id: cachedImage

        CacheImage {
          id: image
            asynchronous: true
            sourceUncached: photoUrl //photoCache
            //cache: photoCache
            smooth: photoSmooth
            fillMode: photoAspect
            width: profileImage.width //- 2*photoBorder + 1 //DBG
            height: profileImage.height //- 2*photoBorder + 1 //DBG
            sourceSize.width: width // photoSourceSize
            //sourceSize.height: height //photoSourceSize
            clip: true
        }
    }

    MouseArea {
        anchors.fill: profileImage
        onClicked: {
            profileImage.clicked();
        }
        visible: enableMouseArea
    }
}
