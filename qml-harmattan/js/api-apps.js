/*
 *
 */

.pragma library

api.log("loading api-apps...");

var apps = new ApiObject();
//notifications.debuglevel = 1;

apps.loadRecent = function(page) {
    var call = apiCall(page, "GET", "apps");
    page.waiting_show();
    api.request(call, apps.onLoadRecent);
}
apps.onLoadRecent = function(call, response) {
    call.page.appsModel.clear();
    if (response) {
        response.forEach(function(application) {
            //console.log("LASTAPP: " + JSON.stringify(application));
            call.page.appsModel.append({"application":application});
        });
    }
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
    page.appLoaded();
}

apps.browseApps = function(page) {
    page.waiting_show();
    var type = page.options.type;
    var template = "";
    switch(type) {
    case "category":
        template = "categories/%1/apps";
        break;
    case "user":
        template = "users/%1/apps";
        break;
    }
    var url = template.arg(page.options.id);
    var params = {"page": page.page};
    var call = apiCall(page, "GET", url, params);
    api.request(call, apps.onBrowseApps);
};

apps.onBrowseApps = function(call, response) {
    call.page.appsModel.clear();
    response.forEach(function(application) {
        //console.log("LASTAPP: " + JSON.stringify(application));
        call.page.appsModel.append({"application":application});
    });
    call.page.waiting_hide();
}

apps.loadComments = function(page, appid) {
    page.waiting_show();
    var call = apiCall(page,"GET", "apps/" + appid + "/comments");
    api.request(call, apps.onLoadComments);
};

apps.onLoadComments = function(call, response) {
    var page = call.page;
    page.waiting_hide();
    page.commentsModel.clear();
    response.forEach(function(comment){
         page.commentsModel.append(comment);
    });
}
