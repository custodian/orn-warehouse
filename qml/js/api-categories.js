/*
 *
 */

.pragma library

api.log("loading api-categories...");

var categories = new ApiObject();
categories.debuglevel = 1;

categories.preload = function(callback) {
    var call = apiCall(null,"GET","categories");
    call.callback = callback;
    api.request(call, categories.onPreloadSuccess, categories.onPreloadFailed);
}

categories.onPreloadSuccess = function(call, response) {
    categories._list = response;
    categories._fulllist = {};
    response.forEach(function(cat) {
        categories._fulllist[cat.tid] = cat;
        if (cat.childrens !== undefined) {
            cat.childrens.forEach(function(child) {
                categories._fulllist[child.tid] = child;
            });
        }
    });
    call.callback();
}
categories.onPreloadFailed = function(call, response) {
    categories.log("FAILED TO GET CATEGORIES");
    call.callback();
}

categories.parse = function(cats, style) {
    var text = "";
    cats.forEach(function(cat) {
        if (style === "small") {
            text = categories._fulllist[cat.tid].name;
        } else {
            if (text.length > 0) {
                text += " > "
            }
            text += categories._fulllist[cat.tid].name;
        }
    });
    return text;
}

categories.loadCategories = function(page) {
    page.categories = categories._list;
};

//Preload categories
//categories.preload();
