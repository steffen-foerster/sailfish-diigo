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
import "../../components"
import "PinboardService.js" as PinboardService
import "../Settings.js" as Settings
import "../AppState.js" as AppState
import "../Utils.js" as Utils

/**
 * Service: Pinboard
 * Startpage shows the recentenly created bookmarks or a search result.
 */
Page {
    id: startPage

    // Result of the last check
    property bool signedIn: false

    property string pageHeader: qsTr("Your recent bookmarks")

    onStatusChanged: {
        if (status === PageStatus.Active) {
            startPage.signedIn = isSignedIn();
            if (startPage.signedIn) {
                console.log("signed in");
                setActiveCover();
            }
            else {
                console.log("not signed in");
                setInactiveCover();
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
        width: parent.width
        spacing: Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: (startPage.signedIn ? qsTr("Settings") : qsTr("Sign in / Settings"))
                onClicked: {
                    getAppContext().state = AppState.T_START_SETTINGS;
                    pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                   refreshCache();
                }
                visible: startPage.signedIn
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

        model: ListModel {
            id: bookmarkModel
        }

        property Item contextMenu

        delegate: ListItem {
            id: wrapper
            property bool menuOpen: {
                bookmarkList.contextMenu != null
                        && bookmarkList.contextMenu.parent === wrapper
            }

            contentHeight: {
                menuOpen ? bookmarkList.contextMenu.height + itemColumn.height
                         : itemColumn.height
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ViewBookmarkPage.qml"),
                               {bookmark: bookmarkModel.get(index)});
            }

            onPressAndHold: {
                if (!bookmarkList.contextMenu) {
                    bookmarkList.contextMenu =
                            contextMenuComponent.createObject(bookmarkList)
                }
                bookmarkList.contextMenu.index = index
                bookmarkList.contextMenu.show(wrapper);
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
                    font {
                        pixelSize: Theme.fontSizeSmall
                        bold: model.toread === 'yes'
                    }
                    wrapMode: Text.Wrap
                    text: model.description
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
                    text: Utils.formatTimestamp(model.time)
                    Image {
                        anchors {
                            verticalCenter: lbCreated.verticalCenter
                            left: lbCreated.right
                            leftMargin: Theme.paddingMedium
                        }
                        height: Theme.iconSizeSmall
                        fillMode: Image.PreserveAspectFit
                        source: "image://theme/icon-m-device-lock"
                        visible: model.shared === 'no'
                    }
                }
            }
        }

        Component {
            id: contextMenuComponent
            ContextMenu {
                property variant index

                MenuItem {
                    text: "Open in browser"
                    onClicked: {
                        console.log("opening URL: " + bookmarkModel.get(index).href)
                        Qt.openUrlExternally(bookmarkModel.get(index).href)
                    }
                }
                MenuItem {
                    text: "Delete"
                    onClicked: {
                        remorse.execute(bookmarkList.contextMenu.parent,
                                        "Deleting",
                                        getDeleteFunction(bookmarkModel, index),
                                        3000)
                    }
                }
                MenuItem {
                    text: "Copy URL to clipboard"
                    onClicked: {
                        Clipboard.text = bookmarkModel.get(index).href
                    }
                }

                function getDeleteFunction(model, index) {
                    // Removing from list destroys the ListElement so we need a copy
                    var itemToDelete = PinboardService.copyBookmark(model.get(index));
                    var f = function() {
                        model.remove(index);
                        PinboardService.deleteBookmark(itemToDelete, function() {},
                            function() {
                                // error -> insert removed item
                                bookmarkModel.insert(index, itemToDelete)
                            }
                        )
                    }
                    return f;
                }
            }
        }

        RemorseItem { id: remorse }

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
        // back from bookmark view
        if (state === AppState.T_VIEW_BOOKMARK_START) {
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
        // Refresh cache after selection of service (manual or auto)
        // or new settings (e.g. first sign in)
        if (state === AppState.T_SERVICE_START || state === AppState.T_SETTINGS_ACCEPTED) {
            refreshCache();
            return;
        }

        searchBookmarksBySavedCriteria();
    }

    function refreshCache() {
        console.log("refreshCache");

        bookmarkModel.clear();
        message.visible = false;

        message.signedIn = startPage.signedIn;
        if (startPage.signedIn) {
            busyIndicator.running = true;
            PinboardService.refreshCache(searchBookmarksBySavedCriteria, serviceErrorCallback);
        }
        else {
            message.visible = true;
        }
    }

    function searchBookmarksBySavedCriteria() {
        console.log("searchBookmarksBySavedCriteria");

        pageHeader = qsTr("Your recent bookmarks")
        bookmarkModel.clear();
        message.visible = false;

        message.signedIn = startPage.signedIn;
        if (startPage.signedIn) {
            busyIndicator.running = true;

            // TODO Load saved search criteria and title
            var count = Settings.get(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS);
            PinboardService.fetchRecentBookmarks(
                        count, fetchBookmarksSuccessCallback, serviceErrorCallback, getAppContext());
        }
        else {
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

        PinboardService.addBookmark(getAppContext().dialogProperties,
                                    addBookmarkSuccessCallback,
                                    serviceErrorCallback)
    }

    function searchBookmarks() {
        console.log("searchBookmarks");

        bookmarkModel.clear();
        message.visible = false;
        busyIndicator.running = true;
        pageHeader = qsTr("Search result");
        getAppContext().state = AppState.S_SEARCH_WAIT_SERVICE;

        PinboardService.fetchBookmarks(getAppContext().dialogProperties,
                                       fetchBookmarksSuccessCallback,
                                       serviceErrorCallback)
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
        message.serviceResult = error;
        message.serviceError = true;
        message.visible = true;
        getAppContext().state = AppState.S_START;
    }
}
