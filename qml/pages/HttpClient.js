/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

I used some ideas of the file
https://github.com/tworaz/sailfish-ytplayer/pages/YoutubeClientV3.js
from Peter Tworek for the below JavaScript.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

.pragma library

/**
 * Performs an async GET request.
 * It's mandatory to send the credentails for the method "GET", too.
 */
function performGetRequest(url, queryParams, onSuccess, onFailure, user, password) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        private.onReady(request, onSuccess, onFailure);
    }

    url += ("?");
    for (var paramKey in queryParams) {
        url += ("&" + paramKey + "=" + queryParams[paramKey])
    }
    console.log("URL: ", url);

    request.open("GET", url, true, user, password);
    request.send();
}

/**
 * Performs an async POST request.
 */
function performPostRequest (url, queryParams, onSuccess, onFailure, user, password) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        private.onReady(request, onSuccess, onFailure);
    }

    var content = private.createPostBody(queryParams);
    request.open("POST", url, true, user, password);
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Content-Length', content.length);
    request.send(content);
};

var private = {

    createPostBody : function(queryParams) {
        var content = "";
        for (var paramKey in queryParams) {
            if (content.length > 0) {
                content += "&";
            }
            content += (paramKey + "=" + escape(queryParams[paramKey]))
        }
        return content;
    },

    onReady : function(request, onSuccess, onFailure) {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var response = JSON.parse(request.responseText);
                console.log("response: ", response)
                onSuccess(response);
            } else {
                var errorResponse = this.handleError(request);
                onFailure(errorResponse);
            }
        }
    },

    /**
     * Performs logging of the error and returns an error message for the user.
     */
    handleError : function(request) {
        var result = {message : "Service is unavailable"};

        if (request.status === 400) {
            console.log("status ", request.status,
                        " - Some request parameters are invalid or the API rate limit is exceeded");
        }
        else if (request.status === 401) {
            console.log("status ", request.status,
                        " - Authentication credentials are missing or invalid");
            result = {message : "Authentication failed"};
        }
        else if (request.status === 403) {
            console.log("status ", request.status,
                        " - The request has been refused because of the lack of proper permission");
            result = {message : "Authentication failed"};
        }
        else if (request.status === 404) {
            console.log("status ", request.status,
                        " - Either you're requesting an invalid URI or the resource in question doesn't exist (e.g. no such user)");
        }
        else if (request.status === 500) {
            console.log("status ", request.status,
                        " - Something is broken");
        }
        else if (request.status === 502) {
            console.log("status ", request.status,
                        " - Diigo is down or being upgraded");
        }
        else if (request.status === 503) {
            console.log("status ", request.status,
                        " - The Diigo servers are too busy to server your request.");
        }
        return result;
    }
}
