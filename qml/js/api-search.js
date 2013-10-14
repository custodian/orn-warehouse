/*
 *
 */

.pragma library

api.log("loading api-search...");

var search = new ApiObject();
//notifications.debuglevel = 1;

search.apps = function(page, query) {
    var call = apiCall(page, "GET", "search/apps", {"keys":query});
    page.waiting_show();
    api.request(call, search.onAppsSearch);
}
search.onAppsSearch = function(call, response) {
    call.page.appsModel.clear();
    response.forEach(function(application) {
        call.page.appsModel.append({"application":application});
    });
    call.page.waiting_hide();
};
