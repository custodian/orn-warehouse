/*
 * Foursquare API bindings
 */
.pragma library

console.log("loading api...");

function ApiObject() {
    this.name = "OpenRepos JS API for QML";
    this.debuglevel = 1; //1 = log, 2 = debug
    this.log = function(msg) {
        if (this.debuglevel > 0) {
            //console.log("LOG: " + msg)
            console.log(msg)
        }
    }
    this.debug = function(callback) {
        if (this.debuglevel > 1) {
            console.debug(callback());
        }
    }
}
var api = new ApiObject();

Qt.include("qmlprivate.js")

Qt.include("api-core.js")
Qt.include("api-apps.js")
Qt.include("api-categories.js")
Qt.include("api-search.js")
/*
Qt.include("api-users.js")

Qt.include("api-comments.js")


Qt.include("utils.js")
Qt.include("debug.js")
*/

console.log("api loaded.");
