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
.import "HttpClient.js" as HttpClient
.import "Settings.js" as Settings

/**
 * Documentation of the Diigo API: https://www.diigo.com/api_dev
 */
var Instance = {

    URL_FETCH_BOOKMARK : "https://secure.diigo.com/api/v2/bookmarks",

    SORT_CREATED_AT : 0,

    SORT_UPDATED_AT : 1,

    SORT_POPULARITY : 2,

    SORT_HOT : 3,

    FILTER_ALL : "all",

    FILTER_PUBLIC : "public",

    /**
     * Returns the last created bookmarks.
     */
    getLastBookmarks : function(count, onSuccess, onFailure, apiKey) {
        var queryParams = {
            user : Settings.Instance.getUser(),
            start : 0,
            count : count,
            sort : this.SORT_CREATED_AT,
            filter : this.FILTER_ALL
        }

        HttpClient.Instance.performGetRequest(
                    this.URL_FETCH_BOOKMARK,
                    queryParams,
                    onSuccess,
                    onFailure,
                    Settings.Instance.getUser(),
                    Settings.Instance.getPassword(),
                    apiKey);
    }
}


