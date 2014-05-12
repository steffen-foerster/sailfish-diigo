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

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/Settings.js" as Settings
import "PinboardService.js" as PinboardService
import "DiigoService.js" as DiigoService
import "LocalService.js" as LocalService
import "Services.js" as Services

QtObject {
    id: root

    function startService(service) {
        Settings.set(Services.ALL, Settings.keys.SERVICE, service);
        getAppContext().service = service;

        if (isSignedIn()) {
            var page = pageStack.replace(getMainPage());
            page.initialize();
        }
        else {
            pageStack.replace(getSignInPage());
        }
    }

    function getSettingsDialog() {
        if (getAppContext().service === Services.DIIGO) {
            return Qt.createComponent("../pages/diigo/SettingDialog.qml");
        }
        else if (getAppContext().service === Services.PINBOARD) {
            return Qt.createComponent("../pages/pinboard/SettingDialog.qml");
        }
        else if (getAppContext().service === Services.LOCAL) {
            return Qt.createComponent("../pages/local/SettingDialog.qml");
        }
    }

    function getServiceName() {
        if (getAppContext().service === Services.DIIGO) {
            return "DIIGO";
        }
        else if (getAppContext().service === Services.PINBOARD) {
            return "PINBOARD";
        }
        else if (getAppContext().service === Services.LOCAL) {
            return "PHONE";
        }
    }

    /**
     * Refresh cache if it exists.
     */
    function refresh(onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.refreshCache(onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.DIIGO) {
            DiigoService.refreshCache(onSuccess, onFailure, getAppContext());
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.refreshCache(onSuccess, onFailure);
        }
    }

    function deleteBookmark(bookmark, onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.deleteBookmark(bookmark, onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.deleteBookmark(bookmark, onSuccess, onFailure);
        }
    }

    function fetchRecentBookmarks(onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.fetchRecentBookmarks(onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.DIIGO) {
            DiigoService.fetchRecentBookmarks(onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.fetchRecentBookmarks(onSuccess, onFailure);
        }
    }

    function fetchBookmarks(criteria, onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.fetchBookmarks(criteria, onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.DIIGO) {
            DiigoService.fetchBookmarks(criteria, onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.fetchBookmarks(criteria, onSuccess, onFailure);
        }
    }

    function addBookmark(bookmark, onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.addBookmark(bookmark, onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.DIIGO) {
            DiigoService.addBookmark(bookmark, onSuccess, onFailure, getAppContext());
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.addBookmark(bookmark, onSuccess, onFailure);
        }
    }

    function updateBookmark(bookmark, onSuccess, onFailure) {
        if (getAppContext().service === Services.PINBOARD) {
            PinboardService.updateBookmark(bookmark, onSuccess, onFailure);
        }
        else if (getAppContext().service === Services.DIIGO) {
            DiigoService.updateBookmark(bookmark, onSuccess, onFailure, getAppContext());
        }
        else if (getAppContext().service === Services.LOCAL) {
            LocalService.updateBookmark(bookmark, onSuccess, onFailure);
        }
    }

    function getTags() {
        if (getAppContext().service === Services.PINBOARD) {
            return PinboardService.getTags();
        }
        else if (getAppContext().service === Services.DIIGO) {
            return DiigoService.getTags();
        }
        else if (getAppContext().service === Services.LOCAL) {
            return LocalService.getTags();
        }
    }
}
