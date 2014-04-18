/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

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

var Instance = {

    /**
     * Performs an async GET request.
     */
    performGetRequest: function(url, queryParams, onSuccess, onFailure, user, password, apiKey) {
        var request = new XMLHttpRequest();
        request.onreadystatechange = function() {
            Instance.onReady(request, onSuccess, onFailure);
        }

        url += ("?key=" + apiKey);
        for (var paramKey in queryParams) {
            url += ("&" + paramKey + "=" + queryParams[paramKey])
        }
        console.log("URL: ", url);

        request.open("GET", url, true, user, password);
        request.send();
    },

    asyncFormPost: function (url, content, onSuccess, onFailure) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    onSuccess(response);
                } else {
                    var details = xhr.responseText ? JSON.parse(xhr.responseText) : undefined;
                    onFailure({ "code" : xhr.status, "details" : details });
                }
            }
        }
        xhr.open("POST", url);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.setRequestHeader('Content-Length', content.length);
        if (isAuthEnabled()) {
            xhr.setRequestHeader("Authorization", _getAuthHeader());
        }
        xhr.send(content);
    },

    onReady : function(request, onSuccess, onFailure) {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status === 200) {
                var response = JSON.parse(request.responseText);
                console.log("response: ", response)
                onSuccess(response);
            } else {
                var errorResponse = Instance.handleError(request);
                onFailure(errorResponse);
            }
        }
    },

    /**
     * Performs logging of the error and returns an error message for the user.
     */
    handleError : function(request) {
        var result = {message : "Diigo service is unavailable. Please try again later."};

        if (request.status === 400) {
            console.log("status ", request.status,
                        " - Some request parameters are invalid or the API rate limit is exceeded");
        }
        else if (request.status === 401) {
            console.log("status ", request.status,
                        " - Authentication credentials are missing or invalid");
            result = {message : "Authentication failed."};
        }
        else if (request.status === 403) {
            console.log("status ", request.status,
                        " - The request has been refused because of the lack of proper permission");
            result = {message : "Authentication failed."};
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
