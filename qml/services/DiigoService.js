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
.import "../js/Utils.js" as Utils
.import "../js/Settings.js" as Settings
.import "../js/Bookmark.js" as Bookmark
.import "../js/LocalStore.js" as LocalStore
.import "Services.js" as Services

/**
 * Documentation of the Diigo API: https://www.diigo.com/api_dev
 */

var COUNT_FETCH_ALL = 100;

function refreshCache(onSuccess, onFailure, appContext) {
    var lastSync = Settings.get(Services.DIIGO, Settings.keys.LAST_SYNC);
    console.log("lastSync: " + lastSync);
    if (!lastSync || internal.canFetchAll(lastSync)) {
        internal.fetchBookmarks(onSuccess, onFailure, appContext, 0, []);
    }
    else {
        onSuccess();
    }
}

/**
 * Returns the recent created bookmarks from the cache.
 */
function fetchRecentBookmarks(onSuccess, onFailure) {
    var count = Settings.get(Services.DIIGO, Settings.keys.COUNT_RECENT_BOOKMARKS);
    var bookmarks = LocalStore.fetchRecentBookmarks(count, Services.DIIGO);
    onSuccess(bookmarks);
}

/**
 * Returns the bookmarks which fulfills the criteria.
 */
function fetchBookmarks(criteria, onSuccess, onFailure) {
    var bookmarks = LocalStore.searchBookmarks(criteria, Services.DIIGO);
    onSuccess(bookmarks);
}

/**
 * Saves the given bookmark.
 *
 * API Fields:
 *
 * title:     required, string, 1-250
 * url:       required, string, 1-250
 * shared:    optional, string (yes/no)
 * tags:      optional, string, 1-250, comma separated
 * desc:      optional, string, 1-250
 * readLater: optional, string (yes/no)
 */
function addBookmark(bookmark, onSuccess, onFailure, appContext) {
    var queryParams = {
        key: appContext.diigoApiKey,
        user: Settings.get(Services.DIIGO, Settings.keys.USER),
        title: bookmark.title,
        url: bookmark.href,
        shared: bookmark.shared,
        readLater: bookmark.toread
    }
    if (bookmark.tags !== undefined && bookmark.tags.length > 0) {
        queryParams.tags = Utils.spaceToCommaSeparated(bookmark.tags);
    }
    if (bookmark.desc !== undefined && bookmark.desc.length > 0) {
        queryParams.desc = bookmark.desc;
    }

    HttpClient.performPostRequest(
                internal.URL_BOOKMARK,
                queryParams,
                function(result) {internal.addSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure,
                Settings.get(Services.DIIGO, Settings.keys.USER),
                Settings.getPassword(appContext));
}

/**
 * Updates the given bookmark.
 */
function updateBookmark(bookmark, onSuccess, onFailure, appContext) {
    var queryParams = {
        key: appContext.diigoApiKey,
        user: Settings.get(Services.DIIGO, Settings.keys.USER),
        title: bookmark.title,
        url: bookmark.href,
        shared: bookmark.shared,
        readLater: bookmark.toread
    }
    if (bookmark.tags !== undefined && bookmark.tags.length > 0) {
        queryParams.tags = Utils.spaceToCommaSeparated(bookmark.tags);
    }
    if (bookmark.desc !== undefined && bookmark.desc.length > 0) {
        queryParams.desc = bookmark.desc;
    }

    HttpClient.performPostRequest(
                internal.URL_BOOKMARK,
                queryParams,
                function(result) {internal.updateSuccessCallback(result, bookmark, onSuccess, onFailure)},
                onFailure,
                Settings.get(Services.DIIGO, Settings.keys.USER),
                Settings.getPassword(appContext));
}

function getTags() {
    return LocalStore.getTags(Services.DIIGO);
}

// -------------------------------------------------------
// private section
// -------------------------------------------------------

var internal = {

    URL_BOOKMARK: "https://secure.diigo.com/api/v2/bookmarks",

    SEARCH_PARAMS: {
        SORT_CREATED_AT : 0,

        SORT_UPDATED_AT : 1,

        SORT_POPULARITY : 2,

        SORT_HOT : 3,

        FILTER_ALL : "all",

        FILTER_PUBLIC : "public"
    },

    /**
     * Diigo hasn't a fixed limit for fetching of bookmarks.
     * We fetch only all bookmarks every 300 seconds.
     */
    canFetchAll: function(lastSync) {
        var dateLastSync = Date.parse(lastSync);
        var now = Date.now();
        var diffSeconds = (now - dateLastSync) / (1000);
        var delay = 300;
        console.log("diffSeconds: ", diffSeconds);

        return diffSeconds > delay;
    },

    fetchBookmarks: function(onSuccess, onFailure, appContext, startOffset, allBookmarks) {
        var queryParams = {
            key: appContext.diigoApiKey,
            user: Settings.get(Services.DIIGO, Settings.keys.USER),
            start: startOffset,
            count: COUNT_FETCH_ALL,
            sort: internal.SEARCH_PARAMS.SORT_CREATED_AT,
            filter: internal.SEARCH_PARAMS.FILTER_ALL
        }

        HttpClient.performGetRequest(
                    internal.URL_BOOKMARK,
                    queryParams,
                    function(bookmarks) {
                        internal.fetchCallback(bookmarks, onSuccess, onFailure, appContext, allBookmarks)
                    },
                    onFailure,
                    Settings.get(Services.DIIGO, Settings.keys.USER),
                    Settings.getPassword(appContext));
    },

    fetchCallback: function(fetchedBookmarks, onSuccess, onFailure, appContext, allBookmarks) {
        console.log("fetched bookmarks: " + fetchedBookmarks.length);
        for (var i = 0; i < fetchedBookmarks.length; i++) {
            var guiBookmark = Bookmark.create(
                fetchedBookmarks[i].url,
                fetchedBookmarks[i].title,
                fetchedBookmarks[i].desc,
                Utils.commaToSpaceSeparated(fetchedBookmarks[i].tags),
                fetchedBookmarks[i].shared,
                null,
                internal.replaceSlash(fetchedBookmarks[i].created_at)
            );
            allBookmarks.push(guiBookmark);
        }
        console.log("total fetched bookmarks: " + allBookmarks.length);

        if (fetchedBookmarks.length < COUNT_FETCH_ALL) {
            var nowStr = new Date().toISOString();
            console.log("Save last sync: " + nowStr);
            Settings.set(Services.DIIGO, Settings.keys.LAST_SYNC, nowStr);
            console.log("Save bookmarks ...");
            LocalStore.saveDiigoBookmarks(allBookmarks);
            console.log("back to page");
            onSuccess();
        }
        else {
            // fetch next bookmarks
            var startOffset = allBookmarks.length;
            internal.fetchBookmarks(onSuccess, onFailure, appContext, startOffset, allBookmarks);
        }
    },

    addSuccessCallback: function(result, bookmark, onSuccess, onFailure) {
        console.log("addSuccessCallback, message: " + result.message);
        var msgLower = result.message.toLowerCase();
        if (msgLower.indexOf("saved") > -1 || msgLower.indexOf("added") > -1) {
            console.log("Add bookmark to cache:", bookmark.href);
            LocalStore.addOrUpdateBookmark(bookmark, Services.DIIGO);
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
        console.log("updateSuccessCallback, message: " + result.message);
        var msgLower = result.message.toLowerCase();
        if (msgLower.indexOf("saved") > -1 || msgLower.indexOf("added") > -1) {
            console.log("Update bookmark in cache:", bookmark.href);
            LocalStore.addOrUpdateBookmark(bookmark, Services.DIIGO);
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

    replaceSlash: function(timestamp) {
        return timestamp.replace(/\//g, "-");
    }
}

