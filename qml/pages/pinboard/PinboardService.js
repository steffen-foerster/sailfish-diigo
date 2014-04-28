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

var URL_BOOKMARK = "https://api.pinboard.in/v1/posts/";

var methods = {
    ADD: "add",
    ALL: "all",
    DELETE: "delete",
    RECENT: "recent"
}

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
    if (!lastSync || canFetchAll(lastSync)) {
        var queryParams = {
            auth_token: Settings.get(Settings.services.PINBOARD, Settings.keys.API_KEY),
            format: "json"
        }

        HttpClient.performGetRequest(
                    URL_BOOKMARK + methods.ALL,
                    queryParams,
                    function(posts) {fetchAllSuccessCallback(posts, onSuccess)},
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
 * Saves the given bookmark.
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
        url: bookmark.url,
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
                URL_BOOKMARK + methods.ADD,
                queryParams,
                function(result) {addSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure);
}

// -------------------------------------------------------
// private functions
// -------------------------------------------------------

/**
 * We can only fetch all posts every 5 minutes.
 */
function canFetchAll(lastSync) {
    var dateLastSync = Date.parse(lastSync);
    var now = Date.now();
    var diffSeconds = (now - dateLastSync) / (1000);
    var delay = (5 * 60) + 10; // 10 extra seconds
    console.log("diffSeconds: ", diffSeconds);

    return diffSeconds > delay;
}

// -------------------------------------------------------
// callback functions
// -------------------------------------------------------

function fetchAllSuccessCallback(posts, onSuccess) {
    var nowStr = new Date().toISOString();
    console.log("Save last sync: " + nowStr);
    Settings.set(Settings.services.PINBOARD, Settings.keys.LAST_SYNC, nowStr);
    console.log("Save posts ...");
    LocalStore.savePinboardPosts(posts);
    console.log("back to page");
    onSuccess();
}

function addSuccessCallback(result, bookmark, onSuccess, onFailure) {
    console.log("addSuccessCallback, result code: " + result.code);
    if (result.result_code === "done") {
        // transform to post interface
        var post = {
            href: bookmark.url,
            description: bookmark.description,
            shared: bookmark.shared ? "yes" : "no",
            toread: bookmark.toread ? "yes" : "no",
            tags: (bookmark.tags !== undefined && bookmark.tags.length > 0) ? bookmark.tags : "",
            extended: (bookmark.extended !== undefined && bookmark.extended.length > 0) ? bookmark.extended : ""
        }

        console.log("Add bookmark to cache");
        LocalStore.addPinboardPost(post);
        onSuccess();
    }
    else {
        var errorResponse = {
            errorMessage: qsTr("Cannot execute action"),
            detailMessage : qsTr("Service request failed")
        };
        onFailure(errorResponse);
    }
}
