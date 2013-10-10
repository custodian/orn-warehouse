import Qt 4.7
import "."

import "../js/api.js" as Api

Image {
    id: root

    property string sourceUncached: ""
    property string __sourceUncached: ""

    Image {
        id: loader
        anchors.centerIn: root
        source: "../images/"+mytheme.name+"-loader.png"
        visible: (root.status != Image.Ready && sourceUncached != "")
    }

    onStatusChanged: {
        loader.visible = (root.status != Image.Ready)
        if (root.status == Image.Error) {
            //Error loading
            cache.removeUrl(__sourceUncached);
            cacheLoad();
        }
    }

    onSourceUncachedChanged: {
        //console.log("New url arrived: " + sourceUncached + " Old was: " + __sourceUncached);
        //Remove old queue (if any)
        if (__sourceUncached !== "") {
            cache.dequeueObject(__sourceUncached,root.toString());
            Api.objs.remove(root);
        }
        //setup new url
        __sourceUncached = sourceUncached;
        //load cached image
        cacheLoad();
    }

    function cacheLoad() {
        if (__sourceUncached !== ""
                && __sourceUncached.indexOf("http") !== -1 ) {
            //if valid url - queue cache
            Api.objs.save(root).cacheCallback = cacheCallback;
            cache.queueObject(__sourceUncached,root.toString());
        } else {
            //just reset source
            source = __sourceUncached;
        }
    }

    Component.onDestruction: {
        //remove queue (if any)
        if (__sourceUncached !== "") {
            //console.log("Dequeue cache for: " + __sourceUncached);
            cache.dequeueObject(__sourceUncached,root.toString());
            Api.objs.remove(root);
        }
    }

    function cacheCallback(status, url) {
        //console.log("CacheImage callback: " + url);
        if (status) {
            root.source = url;
        }
    }
}
