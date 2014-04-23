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
import "../components"
import "DiigoService.js" as DiigoService
import "Settings.js" as Settings
import "AppState.js" as AppState

/**
 * Startpage shows the recentenly created bookmarks.
 */
Page {
    id: startPage

    // Result of the last check
    property bool signedIn: false

    property string pageHeader: qsTr("Your recent bookmarks")

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // TODO: Find better place to initialize the database.
            if (getAppContext().state === AppState.T_MAIN_START) {
                Settings.initialize();
            }

            preparePage();
        }
    }

    Item {
        anchors.fill: parent
        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            running: false
            size: BusyIndicatorSize.Large
        }
    }

    SilicaListView {
        id: bookmarkList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: (startPage.signedIn ? qsTr("Settings") : qsTr("Sign in / Settings"))
                onClicked: {
                    getAppContext().state = AppState.T_START_SETTINGS;
                    pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: {
                    getAppContext().state = AppState.T_START_SEARCH;
                    pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
                }
                visible: startPage.signedIn
            }
            MenuItem {
                text: qsTr("Add bookmark")
                onClicked: {
                    getAppContext().state = AppState.T_START_ADD;
                    pageStack.push(Qt.resolvedUrl("AddBookmarkPage.qml"))
                }
                visible: startPage.signedIn
            }
        }

        header : PageHeader {
            title: pageHeader
        }

        MessageBookmarkList {
            id: message
            count: bookmarkModel.count
        }

        width: parent.width
        spacing: Theme.paddingLarge

        model: ListModel {
            id: bookmarkModel
        }
        delegate: ListItem {
            id: wrapper
            contentHeight: itemColumn.height

            onClicked: {
                console.log("opening URL: " + url)
                Qt.openUrlExternally(url)
            }

            Column {
                id: itemColumn
                Label {
                    anchors {
                        left: parent.left
                        //right: parent.right
                        margins: Theme.paddingLarge
                    }
                    id: lbTitle
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    text: title
                    width: wrapper.ListView.view.width - (2 * Theme.paddingLarge)
                }
                Label {
                    id: lbCreated
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: formatTimestamp(created_at)
                }
            }

        }
        VerticalScrollDecorator {}
    }

    function preparePage() {
        var state = getAppContext().state;
        console.log("preparePage, state: " + state);

        // a dialog as rejected -> page isn't refreshed
        if (state === AppState.T_ADD_REJECTED
                || state === AppState.T_SETTINGS_REJECTED
                || state === AppState.T_SEARCH_REJECTED) {
            getAppContext().state = AppState.S_START;
            return;
        }
        // we are waiting for the service result
        if (state === AppState.S_ADD_WAIT_SERVICE
                || state === AppState.S_SEARCH_WAIT_SERVICE) {
            return;
        }
        // page was refreshed -> service has finished before page transition
        if (state === AppState.S_START) {
            return;
        }
        if (state === AppState.T_ADD_ACCEPTED) {
            addBookmark();
            return;
        }
        if (state === AppState.T_SEARCH_ACCEPTED) {
            searchBookmarks();
            return;
        }

        searchBookmarksBySavedCriteria();
    }

    function searchBookmarksBySavedCriteria() {
        console.log("searchBookmarksBySavedCriteria");

        pageHeader = qsTr("Your recent bookmarks")
        bookmarkModel.clear();
        message.visible = false;

        startPage.signedIn = isSignedIn();
        message.signedIn = startPage.signedIn;
        if (startPage.signedIn) {
            console.log("signed in");
            busyIndicator.running = true;

            // TODO Load saved search criteria and title
            var count = Settings.get(Settings.keys.COUNT_RECENT_BOOKMARKS);
            DiigoService.getRecentBookmarks(
                        count, fetchBookmarksSuccessCallback, serviceErrorCallback, getAppContext());
        }
        else {
            console.log("not signed in");
            message.visible = true;
        }
        getAppContext().state = AppState.S_START;
    }

    function addBookmark() {
        console.log("addBookmark");

        pageHeader = qsTr("Your recent bookmarks")
        bookmarkModel.clear();
        message.visible = false;
        busyIndicator.running = true;
        getAppContext().state = AppState.S_ADD_WAIT_SERVICE;

        DiigoService.addBookmark(getAppContext().dialogProperties,
                                 addBookmarkSuccessCallback,
                                 serviceErrorCallback,
                                 getAppContext())
    }

    function searchBookmarks() {
        console.log("searchBookmarks");

        bookmarkModel.clear();
        message.visible = false;
        busyIndicator.running = true;
        pageHeader = qsTr("Search result");
        getAppContext().state = AppState.S_SEARCH_WAIT_SERVICE;

        DiigoService.fetchBookmarks(getAppContext().dialogProperties,
                                    fetchBookmarksSuccessCallback,
                                    serviceErrorCallback,
                                    getAppContext())
    }

    function formatTimestamp(timestamp) {
        return timestamp.substr(0, 10);
    }

    // ---------------------------------------------------------
    // callbacks
    // ---------------------------------------------------------

    function fetchBookmarksSuccessCallback(bookmarks) {
        console.log("fetchBookmarksSuccessCallback");

        message.serviceError = false;
        busyIndicator.running = false;
        bookmarkModel.clear();

        for (var i = 0; i < bookmarks.length; i++) {
            bookmarkModel.append(bookmarks[i]);
        }

        message.visible = bookmarkModel.count === 0;
        getAppContext().state = AppState.S_START;
    }

    function addBookmarkSuccessCallback() {
        console.log("addBookmarkSuccessCallback");

        message.serviceError = false;
        busyIndicator.running = false;
        getAppContext().state = AppState.T_ADD_SERVICE_RESULT_RECIEVED;
        preparePage();
    }

    function serviceErrorCallback(error) {
        console.log("serviceErrorCallback");

        console.error(error.detailMessage);
        bookmarkModel.clear();
        busyIndicator.running = false;
        message.serviceError = true;
        message.serviceResult = error;
        message.visible = true;
        getAppContext().state = AppState.S_START;
    }
}
