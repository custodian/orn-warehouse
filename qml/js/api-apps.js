/*
 *
 */

.pragma library

api.log("loading api-notifications...");

var apps = new ApiObject();
//notifications.debuglevel = 1;

apps.loadRecent = function(page) {
    var call = apiCall(page, "GET", "apps");
    api.request(call, apps.onLoadRecent, apps.onLoadRecentError);
}

apps.onLoadRecent = function(call, response) {
    call.page.appsModel.clear();
    response.forEach(function(application) {
        //console.log("LASTAPP: " + JSON.stringify(application));
        call.page.appsModel.append({"application":application});
    });
};
apps.onLoadRecentError = function(call, error, code) {
    console.log("Error: " + error + " Code: " + code);
};
