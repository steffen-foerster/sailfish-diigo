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

/**
 * Documentation of the Diigo API: https://www.diigo.com/api_dev
 */

/**
 * Returns the recent created bookmarks.
 */
function getRecentBookmarks(count, onSuccess, onFailure, appContext) {
    var queryParams = {
        key: appContext.apiKey,
        user: Settings.get(Settings.services.DIIGO, Settings.keys.USER),
        start: 0,
        count: count,
        sort: internal.SEARCH_PARAMS.SORT_CREATED_AT,
        filter: internal.SEARCH_PARAMS.FILTER_ALL
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK,
                queryParams,
                onSuccess,
                onFailure,
                Settings.get(Settings.services.DIIGO, Settings.keys.USER),
                Settings.getPassword(appContext));
}

/**
 * Returns the bookmarks to the given criteria.
 */
function fetchBookmarks(searchCriteria, onSuccess, onFailure, appContext) {
    var queryParams = {
        key: appContext.apiKey,
        user: Settings.get(Settings.services.DIIGO, Settings.keys.USER),
        start: 0,
        count: searchCriteria.count,
        sort: searchCriteria.sort,
        filter: searchCriteria.filter ? internal.SEARCH_PARAMS.FILTER_ALL : internal.SEARCH_PARAMS.FILTER_PUBLIC,
    }
    if (searchCriteria.tags !== undefined && searchCriteria.tags.length > 0) {
        queryParams.tags = searchCriteria.tags
    }
    if (searchCriteria.list !== undefined && searchCriteria.list.length > 0) {
        queryParams.list = searchCriteria.list
    }

    HttpClient.performGetRequest(
                internal.URL_BOOKMARK,
                queryParams,
                onSuccess,
                onFailure,
                Settings.get(Settings.services.DIIGO, Settings.keys.USER),
                Settings.getPassword(appContext));
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
        key: appContext.apiKey,
        user: Settings.get(Settings.services.DIIGO, Settings.keys.USER),
        title: bookmark.title,
        url: bookmark.url,
        shared: bookmark.shared ? "yes" : "no",
        readLater: bookmark.readLater ? "yes" : "no"
    }
    if (bookmark.tags !== undefined && bookmark.tags.length > 0) {
        queryParams.tags = bookmark.tags
    }
    if (bookmark.desc !== undefined && bookmark.desc.length > 0) {
        queryParams.desc = bookmark.desc
    }

    HttpClient.performPostRequest(
                internal.URL_BOOKMARK,
                queryParams,
                onSuccess,
                onFailure,
                Settings.get(Settings.services.DIIGO, Settings.keys.USER),
                Settings.getPassword(appContext));
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
    }

}

