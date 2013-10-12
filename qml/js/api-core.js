/*
 * Foursquare API bindings
 */

.pragma library

api.log("loading api-core...");

//Options
api.accessToken = "";
api.inverted = false; //TODO: have to move this somewhere to make common function with icons work
api.locale = "en";

//Const section
api.VERSION = "v1";
api.URL = "https://openrepos.net/api/";
//api.URL = "http://dev.openrepos.net/api/";

//api.DEBUG_URL = "http://thecust.net/debug-warehouse.php?content="

function setLocale(locale) {
    api.locale = locale;
}

function apiCall(page, type, url, params) {
    var data = {
        "page": page,
        "type": type,
        "url": url
    };
    if (params !== undefined) {
        data.params = params;
    };
    return data;
};

api.onErrorDefault = function(call, error, status) {
    call.page.show_error(error);
};

api.request = function(call, onSuccess, onErrorCustom) {
    api.log(call.type + " " + call.url);//.replace(/oauth\_token\=([A-Z0-9]+).*\&v\=.*/gm,""));
    var url = api.URL + api.VERSION + "/" + call.url;

    var onError = api.onErrorDefault;
    if (onErrorCustom !== undefined) {
        onError = onErrorCustom;
    }

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                onError(call, "API returned " + status + " " + doc.statusText, status);
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status == 200) {
                var data;
                var contentType = doc.getResponseHeader("Content-Type");
                data = api.process(doc.responseText);
                onSuccess(call, data);
            } else {
                if (doc.status == 0) {
                    onError(call, "Network connection error");
                } else {
                    onError(call, "General error: " + doc.status + "<br>" + doc.statusText, status);
                }
            }
        }
    }

    if (call.type === "GET") {
        if (call.params !== undefined) {
            url += "?";
            for (var param in call.params) {
                url += encodeURIComponent(param) + "=" + encodeURIComponent(call.params[param]) + "&";
            }
        }

    }
    doc.open(call.type, url);
    doc.setRequestHeader("Accept-Language",api.locale);
    //doc.setRequestHeader("Accept-Language",api.locale); //SECURITY DATA
    if (call.type === "POST") {
        doc.send(JSON.stringify(call.params));
    }
    doc.send();
}

api.process = function(response) {
    var data = eval("[" + response + "]")[0];
    return data;
}



function setAccessToken(token) {
    //api.debug(function(){return"SET TOKEN: " + token});
    api.accessToken = token;
}
function getAccessTokenParameter() {
    var token = api.accessToken;
    //api.debug(function(){return"GET TOKEN: " + token});
    return "oauth_token=" + token + "&v=" + API_VERSION;
}
