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

.import "../js/HttpClient.js" as HttpClient
.import "../js/Settings.js" as Settings
.import "../js/LocalStore.js" as LocalStore
.import "../js/Bookmark.js" as Bookmark
.import "Services.js" as Services

/**
 * Documentation of the Pinboard API: https://pinboard.in/api/
 */

function refreshCache(onSuccess, onFailure) {
    var lastSync = Settings.get(Services.PINBOARD, Settings.keys.LAST_SYNC);
    console.log("lastSync: " + lastSync);
    if (!lastSync || internal.canFetchAll(lastSync)) {
        var queryParams = {
            auth_token: Settings.get(Services.PINBOARD, Settings.keys.API_KEY),
            format: "json"
        }

        HttpClient.performGetRequest(
                    internal.URL_BOOKMARK + internal.METHODS.ALL,
                    queryParams,
                    function(bookmarks) {internal.fetchAllSuccessCallback(bookmarks, onSuccess)},
                    onFailure);
    }
    else {
        onSuccess();
    }
}

/**
 * Returns the recent created bookmarks from the cache.
 */
function fetchRecentBookmarks(onSuccess, onFailure) {
    var count = Settings.get(Services.PINBOARD, Settings.keys.COUNT_RECENT_BOOKMARKS);
    var bookmarks = LocalStore.fetchRecentBookmarks(count, Services.PINBOARD);
    onSuccess(bookmarks);
}

/**
 * Returns the bookmarks which fulfills the criteria.
 */
function fetchBookmarks(criteria, onSuccess, onFailure) {
    var bookmarks = LocalStore.searchBookmarks(criteria, Services.PINBOARD);
    onSuccess(bookmarks);
}

/**
 * Adds the given bookmark to Pinboard and to the local cache.
 *
 * API Fields:
 *
 * url - the URL of the item
 * description, string, 1-255, Title of the item. This field is unfortunately named 'description' for backwards compatibility with the delicious API
 * extended, string, 0-65536, Description of the item. Called 'extended' for backwards compatibility with delicious API
 * tags, string, 1-255 each, List of up to 100 tags
 * dt, datetime, creation time for this bookmark. Defaults to current time. Datestamps more than 10 minutes ahead of server time will be reset to current server time
 * replace	yes/no	Replace any existing bookmark with this URL. Default is yes. If set to no, will throw an error if bookmark exists
 * shared	yes/no	Make bookmark public. Default is "yes" unless user has enabled the "save all bookmarks as private" user setting, in which case default is "no"
 * toread	yes/no	Marks the bookmark as unread. Default is "no"
 */
function addBookmark(bookmark, onSuccess, onFailure) {
    var queryParams = {
        auth_token: Settings.get(Services.PINBOARD, Settings.keys.API_KEY),
        description: bookmark.title,
        url: bookmark.href,
        shared: bookmark.shared,
        toread: bookmark.toread,
        format: "json"
    }
    if (bookmark.tags !== undefined && bookmark.tags !== null && bookmark.tags.length > 0) {
        queryParams.tags = bookmark.tags;
    }
    if (bookmark.desc !== undefined && bookmark.desc !== null && bookmark.desc.length > 0) {
        queryParams.extended = bookmark.desc;
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK + internal.METHODS.ADD,
                queryParams,
                function(result) {internal.addSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure);
}

/**
 * Updates the bookmark in the Pinboard library and the local cache.
 */
function updateBookmark(bookmark, onSuccess, onFailure) {
    var queryParams = {
        auth_token: Settings.get(Services.PINBOARD, Settings.keys.API_KEY),
        description: bookmark.title,
        url: bookmark.href,
        shared: bookmark.shared,
        toread: bookmark.toread,
        dt: bookmark.time,
        format: "json"
    }
    if (bookmark.tags !== undefined && bookmark.tags !== null && bookmark.tags.length > 0) {
        queryParams.tags = bookmark.tags;
    }
    if (bookmark.desc !== undefined && bookmark.desc !== null && bookmark.desc.length > 0) {
        queryParams.extended = bookmark.desc;
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK + internal.METHODS.ADD,
                queryParams,
                function(result) {internal.updateSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure);
}

/**
 * Deletes the bookmark from the Pinboard library and the local cache.
 */
function deleteBookmark(bookmark, onSuccess, onFailure) {
    var queryParams = {
        auth_token: Settings.get(Services.PINBOARD, Settings.keys.API_KEY),
        url: bookmark.href,
        format: "json"
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK + internal.METHODS.DELETE,
                queryParams,
                function(result) {internal.deleteSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure);
}

function getTags() {
    return LocalStore.getTags(Services.PINBOARD);
}

// -------------------------------------------------------
// private functions
// -------------------------------------------------------

var internal = {

    URL_BOOKMARK: "https://api.pinboard.in/v1/posts/",

    METHODS: {
        ADD: "add",
        ALL: "all",
        DELETE: "delete",
        RECENT: "recent"
    },

    /**
     * We can only fetch all posts every 5 minutes.
     */
    canFetchAll: function(lastSync) {
        var dateLastSync = Date.parse(lastSync);
        var now = Date.now();
        var diffSeconds = (now - dateLastSync) / (1000);
        var delay = (5 * 60) + 10; // 300 + 10 extra seconds
        console.log("diffSeconds: ", diffSeconds);

        return diffSeconds > delay;
    },

    fetchAllSuccessCallback: function(bookmarks, onSuccess) {
        var nowStr = new Date().toISOString();
        console.log("Save last sync: " + nowStr);
        Settings.set(Services.PINBOARD, Settings.keys.LAST_SYNC, nowStr);
        console.log("Save bookmarks ...");
        LocalStore.savePinboardBookmarks(bookmarks);
        console.log("back to page");
        onSuccess();
    },

    addSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("addSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            console.log("Add bookmark to cache");
            LocalStore.addOrUpdateBookmark(bookmark, Services.PINBOARD);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot add bookmark"),
                detailMessage: qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    },

    updateSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("updateSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            console.log("Update bookmark in cache");
            LocalStore.addOrUpdateBookmark(bookmark, Services.PINBOARD);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot update bookmark"),
                detailMessage: qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    },

    deleteSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("deleteSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            console.log("Remove bookmark from cache");
            LocalStore.deleteBookmark(bookmark.href, Services.PINBOARD);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot remove bookmark"),
                detailMessage: qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    }
}
