/*
 *
 */

.pragma library

api.log("loading api-notifications...");

var apps = new ApiObject();
//notifications.debuglevel = 1;

apps.loadRecent = function(page) {
    var call = apiCall(page, "GET", "apps");
    page.waiting_show();
    api.request(call, apps.onLoadRecent);
}
apps.onLoadRecent = function(call, response) {
    call.page.appsModel.clear();
    response.forEach(function(application) {
        //console.log("LASTAPP: " + JSON.stringify(application));
        call.page.appsModel.append({"application":application});
    });
    call.page.waiting_hide();
};

apps.loadApplication = function(page, appid) {
    var call = apiCall(page, "GET", "apps/" + appid);
    page.waiting_show();
    api.request(call,apps.onLoadApplication);
};

apps.onLoadApplication = function(call, response) {
    var page = call.page;
    page.waiting_hide();
    page.application = response;
}
