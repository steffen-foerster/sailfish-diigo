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

.import "LocalStore.js" as LocalStore
.import "../services/Services.js" as Services

var keys = {
    USER: "user",
    PASSWORD: "password",
    SAVE_PASSWORD: "save_password",
    COUNT_RECENT_BOOKMARKS: "count_recent_bookmarks",
    API_KEY: "api_key",
    SERVICE: "service",
    LAST_SYNC: "last_sync"
}

var dBValues = {
    B_TRUE: "true",
    B_FALSE: "false"
}

function get(service, key) {
    return LocalStore.get(service, key);
}

function getBoolean(service, key) {
    return LocalStore.get(service, key) === dBValues.B_TRUE;
}

function set(service, key, value) {
    LocalStore.set(service, key, value);
}

function setBoolean(service, key, value) {
    var booleanStr = value ? dBValues.B_TRUE : dBValues.B_FALSE;
    LocalStore.set(service, key, booleanStr);
}

/**
 * We need only for Diigo a password.
 */
function getPassword(appContext) {
    console.log("getPassword, service " + appContext.service);
    var password = undefined
    if (getBoolean(appContext.service, keys.SAVE_PASSWORD)) {
        console.log("return password from store");
        password = get(appContext.service, keys.PASSWORD);
    }
    else {
        console.log("return password from context");
        password = appContext.password;
    }
    return password;
}

function setPassword(password, save, appContext) {
    if (save) {
        set(appContext.service, keys.PASSWORD, password);
        appContext.password = "";
    }
    else {
        set(appContext.service, keys.PASSWORD, "");
        appContext.password = password;
    }
}

/**
 * Pinboard uses an user specific API-Key.
 */
function getApiKey(appContext) {
    return get(appContext.service, keys.API_KEY);
}

function isSignedIn(appContext) {
    var retval = false;
    if (appContext.service === Services.DIIGO) {
        var user = get(appContext.service, keys.USER);
        var password = getPassword(appContext);
        var hasUser = (user !== undefined && user.length > 0);
        console.log("hasUser: " + hasUser);
        var hasPassword = (password !== undefined && password.length > 0);
        console.log("hasPassword: " + hasPassword);
        retval = hasUser && hasPassword;
    }
    else if (appContext.service === Services.PINBOARD) {
        var apiKey = get(appContext.service, keys.API_KEY);
        retval = (apiKey !== undefined && apiKey.length > 0);
    }
    return retval;
}

/**
 * Should be invoked after application start.
 */
function initialize() {
    var defaultValues = [{
        service: Services.DIIGO,
        values: {
          user: "",
          password: "",
          save_password: dBValues.B_FALSE,
          count_recent_bookmarks: 10
        }
      }, {
        service: Services.PINBOARD,
        values: {
          api_key: "",
          count_recent_bookmarks: 10
        }
      }, {
        service: Services.ALL,
        values: {
          service: Services.NOT_SELECTED
        }
      }
    ];

    LocalStore.initializeDatabase(defaultValues);
}
