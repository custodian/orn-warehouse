/*
 *
 */

.pragma library

api.log("loading api-categories...");

var categories = new ApiObject();
//notifications.debuglevel = 1;

categories.preload = function() {
    var call = apiCall(null,"GET","categories");
    var def = api.process('[{"tid":"1","vid":"1","name":"Applications","description":"","format":"filtered_html","weight":"0","depth":0,"parents":["0"],"apps_count":"1080","childrens":[{"tid":"257","vid":"1","name":"_Application","description":null,"format":null,"weight":"0","depth":1,"parents":["1"],"apps_count":"91"},{"tid":"2","vid":"1","name":"Business","description":null,"format":null,"weight":"1","depth":1,"parents":["1"],"apps_count":"14"},{"tid":"3","vid":"1","name":"City guides & maps","description":null,"format":null,"weight":"2","depth":1,"parents":["1"],"apps_count":"16"},{"tid":"4","vid":"1","name":"Entertainment","description":null,"format":null,"weight":"3","depth":1,"parents":["1"],"apps_count":"7"},{"tid":"5","vid":"1","name":"Music","description":null,"format":null,"weight":"4","depth":1,"parents":["1"],"apps_count":"46"},{"tid":"8","vid":"1","name":"Network","description":"","format":"filtered_html","weight":"5","depth":1,"parents":["1"],"apps_count":"187"},{"tid":"6","vid":"1","name":"News & info","description":null,"format":null,"weight":"6","depth":1,"parents":["1"],"apps_count":"21"},{"tid":"7","vid":"1","name":"Photo & video","description":null,"format":null,"weight":"7","depth":1,"parents":["1"],"apps_count":"60"},{"tid":"9","vid":"1","name":"Social Networks","description":null,"format":null,"weight":"8","depth":1,"parents":["1"],"apps_count":"5"},{"tid":"10","vid":"1","name":"Sports","description":null,"format":null,"weight":"9","depth":1,"parents":["1"],"apps_count":"0"},{"tid":"147","vid":"1","name":"System","description":null,"format":null,"weight":"10","depth":1,"parents":["1"],"apps_count":"344"},{"tid":"250","vid":"1","name":"Unknown","description":null,"format":null,"weight":"11","depth":1,"parents":["1"],"apps_count":"0"},{"tid":"11","vid":"1","name":"Utilities","description":null,"format":null,"weight":"12","depth":1,"parents":["1"],"apps_count":"289"}]},{"tid":"12","vid":"1","name":"Games","description":null,"format":null,"weight":"1","depth":0,"parents":["0"],"apps_count":"55","childrens":[{"tid":"256","vid":"1","name":"_Game","description":null,"format":null,"weight":"0","depth":1,"parents":["12"],"apps_count":"46"},{"tid":"13","vid":"1","name":"Action","description":null,"format":null,"weight":"1","depth":1,"parents":["12"],"apps_count":"0"},{"tid":"14","vid":"1","name":"Adventure","description":null,"format":null,"weight":"2","depth":1,"parents":["12"],"apps_count":"2"},{"tid":"15","vid":"1","name":"Arcade","description":null,"format":null,"weight":"3","depth":1,"parents":["12"],"apps_count":"2"},{"tid":"16","vid":"1","name":"Card & casino","description":null,"format":null,"weight":"4","depth":1,"parents":["12"],"apps_count":"0"},{"tid":"17","vid":"1","name":"Education","description":null,"format":null,"weight":"5","depth":1,"parents":["12"],"apps_count":"0"},{"tid":"18","vid":"1","name":"Puzzle","description":null,"format":null,"weight":"6","depth":1,"parents":["12"],"apps_count":"3"},{"tid":"19","vid":"1","name":"Sports","description":null,"format":null,"weight":"7","depth":1,"parents":["12"],"apps_count":"1"},{"tid":"20","vid":"1","name":"Strategy","description":null,"format":null,"weight":"8","depth":1,"parents":["12"],"apps_count":"1"},{"tid":"21","vid":"1","name":"Trivia","description":null,"format":null,"weight":"9","depth":1,"parents":["12"],"apps_count":"0"}]},{"tid":"247","vid":"1","name":"Libraries","description":null,"format":null,"weight":"2","depth":0,"parents":["0"],"apps_count":"1084"}]');
    categories.onPreloadSuccess(call, def);
    api.request(call, categories.onPreloadSuccess, categories.onPreloadFailed);
}

categories.onPreloadSuccess = function(call, response) {
    categories._list = response;
    categories._fulllist = {};
    response.forEach(function(cat) {
        categories._fulllist[cat.tid] = cat;
        cat.childrens.forEach(function(child) {
            categories._fulllist[child.tid] = child;
        });
    });
}
categories.onPreloadFailed = function(call, response) {
    categories.log("FAILED TO GET CATEGORIES");
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
categories.preload();
