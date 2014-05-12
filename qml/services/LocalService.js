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
 * This service uses only the local database.
 */


function refreshCache(onSuccess, onFailure) {
   onSuccess();
}

function fetchRecentBookmarks(onSuccess, onFailure) {
    var count = Settings.get(Services.LOCAL, Settings.keys.COUNT_RECENT_BOOKMARKS);
    var bookmarks = LocalStore.fetchRecentBookmarks(count, Services.LOCAL);
    onSuccess(bookmarks);
}

function fetchBookmarks(criteria, onSuccess, onFailure) {
    var bookmarks = LocalStore.searchBookmarks(criteria, Services.LOCAL);
    onSuccess(bookmarks);
}

function addBookmark(bookmark, onSuccess, onFailure) {
    console.log("Add bookmark");
    LocalStore.addOrUpdateBookmark(bookmark, Services.LOCAL);
    onSuccess();
}

function updateBookmark(bookmark, onSuccess, onFailure) {
    console.log("Update bookmark");
    LocalStore.addOrUpdateBookmark(bookmark, Services.LOCAL);
    onSuccess();
}

function deleteBookmark(bookmark, onSuccess, onFailure) {
    console.log("Remove bookmark");
    LocalStore.deleteBookmark(bookmark.href, Services.LOCAL);
    onSuccess();
}

function getTags() {
    return LocalStore.getTags(Services.LOCAL);
}
