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
.import "../HttpClient.js" as HttpClient
.import "../Settings.js" as Settings
.import "../LocalStore.js" as LocalStore

/**
 * Documentation of the Pinboard API: https://pinboard.in/api/
 */

/**
 * Returns the recent created bookmarks from the cache.
 */
function fetchRecentBookmarks(count, onSuccess, onFailure, appContext) {
    var posts = LocalStore.getRecentPinboardPosts(count);
    onSuccess(posts);
}

function refreshCache(onSuccess, onFailure) {
    var lastSync = Settings.get(Settings.services.PINBOARD, Settings.keys.LAST_SYNC);
    console.log("lastSync: " + lastSync);
    if (!lastSync || internal.canFetchAll(lastSync)) {
        var queryParams = {
            auth_token: Settings.get(Settings.services.PINBOARD, Settings.keys.API_KEY),
            format: "json"
        }

        HttpClient.performGetRequest(
                    internal.URL_BOOKMARK + internal.METHODS.ALL,
                    queryParams,
                    function(posts) {internal.fetchAllSuccessCallback(posts, onSuccess)},
                    onFailure);
    }
    else {
        onSuccess();
    }
}

function fetchBookmarks(criteria, onSuccess, onFailure) {
    var posts = LocalStore.searchPinboardPosts(criteria);
    onSuccess(posts);
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
        auth_token: Settings.get(Settings.services.PINBOARD, Settings.keys.API_KEY),
        description: bookmark.description,
        url: bookmark.href,
        shared: bookmark.shared ? "yes" : "no",
        toread: bookmark.toread ? "yes" : "no",
        format: "json"
    }
    if (bookmark.tags !== undefined && bookmark.tags.length > 0) {
        queryParams.tags = bookmark.tags
    }
    if (bookmark.extended !== undefined && bookmark.extended.length > 0) {
        queryParams.extended = bookmark.extended
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
        auth_token: Settings.get(Settings.services.PINBOARD, Settings.keys.API_KEY),
        description: bookmark.description,
        url: bookmark.href,
        shared: bookmark.shared,
        toread: bookmark.toread,
        dt: bookmark.time,
        format: "json"
    }
    if (bookmark.tags !== undefined && bookmark.tags.length > 0) {
        queryParams.tags = bookmark.tags
    }
    if (bookmark.extended !== undefined && bookmark.extended.length > 0) {
        queryParams.extended = bookmark.extended
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
        auth_token: Settings.get(Settings.services.PINBOARD, Settings.keys.API_KEY),
        url: bookmark.href,
        format: "json"
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK + internal.METHODS.DELETE,
                queryParams,
                function(result) {internal.deleteSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure);
}

function copyBookmark(bookmark) {
    var copy = {
        href: bookmark.href,
        description: bookmark.description,
        tags: bookmark.tags,
        extended: bookmark.extended,
        shared: bookmark.shared,
        toread: bookmark.toread,
        time: bookmark.time
    }
    return copy;
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
        var delay = (5 * 60) + 10; // 10 extra seconds
        console.log("diffSeconds: ", diffSeconds);

        return diffSeconds > delay;
    },

    fetchAllSuccessCallback: function(posts, onSuccess) {
        var nowStr = new Date().toISOString();
        console.log("Save last sync: " + nowStr);
        Settings.set(Settings.services.PINBOARD, Settings.keys.LAST_SYNC, nowStr);
        console.log("Save posts ...");
        LocalStore.savePinboardPosts(posts);
        console.log("back to page");
        onSuccess();
    },

    addSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("addSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            // transform to post interface
            var post = {
                href: bookmark.href,
                description: bookmark.description,
                shared: bookmark.shared ? "yes" : "no",
                toread: bookmark.toread ? "yes" : "no",
                tags: (bookmark.tags !== undefined && bookmark.tags.length > 0) ? bookmark.tags : "",
                extended: (bookmark.extended !== undefined && bookmark.extended.length > 0) ? bookmark.extended : ""
            }

            console.log("Add bookmark to cache");
            LocalStore.addOrUpdatePinboardPost(post);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot add bookmark"),
                detailMessage : qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    },

    updateSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("updateSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            console.log("Update bookmark in cache");
            LocalStore.addOrUpdatePinboardPost(bookmark);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot update bookmark"),
                detailMessage : qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    },

    deleteSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("deleteSuccessCallback, result code: " + result.result_code);
        if (result.result_code === "done") {
            console.log("Remove bookmark from cache");
            LocalStore.deletePinboardPost(bookmark);
            onSuccess();
        }
        else {
            var errorResponse = {
                errorMessage: qsTr("Cannot remove bookmark"),
                detailMessage : qsTr("Service request failed")
            };
            onFailure(errorResponse);
        }
    }
}
