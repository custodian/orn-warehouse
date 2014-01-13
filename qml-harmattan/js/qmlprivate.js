/*
 * Private bindings
 */
.pragma library

api.log("loading private-objects...");

var objs = new Object();

objs._privs = {};

objs.save = function(key) {
    var h = key.toString();
    var o = objs._privs[h];
    if (!o) {
        o = {};
        objs._privs[h] = o;
    }
    return o;
}

objs.get = function(key) {
    var h = key.toString();
    return objs._privs[h];
}

objs.remove = function(key) {
    var h = key.toString();
    var o = objs._privs[h];
    if (o !== undefined) {
        delete objs._privs[h];
    }
}
