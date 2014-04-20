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

/**
 * Startpage shows the recentenly created bookmarks.
 */
Page {
    id: page

    // Result of the last check
    property bool signedIn: false

    property bool settingsInitialized: false

    // Flag controls if the page content should be updated on activation
    property bool refresh: true;

    onStatusChanged: {
        if (status === PageStatus.Active) {
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
                text: (page.signedIn ? qsTr("Settings") : qsTr("Sign in / Settings"))
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
            }
            MenuItem {
                text: qsTr("Add bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("AddBookmarkPage.qml"))
                visible: page.signedIn
            }
        }

        header: PageHeader {
            title: qsTr("Your recent bookmarks")
        }

        MessageBookmarkList {
            id: message
            count: bookmarkModel.count
        }

        width: page.width
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
        // User has rejected a dialog or the page is waiting for a service result
        if (!refresh) {
            return;
        }

        /**
         * TODO: Find better place to initialize the database.
         */
        if (!page.settingsInitialized) {
            Settings.initialize();
            page.settingsInitialized = true;
        }

        busyIndicator.running = false;
        message.visible = false;

        page.signedIn = isSignedIn();
        message.signedIn = page.signedIn;
        if (page.signedIn) {
            console.log("signed in");
            var count = Settings.get(Settings.keys.COUNT_RECENT_BOOKMARKS);
            DiigoService.getRecentBookmarks(
                        count, showBookmarksCallback, showErrorCallback, getAppContext());
        }
        else {
            console.log("not signed in");
            bookmarkModel.clear();
            message.visible = true;
        }
    }

    function waitForServiceResult () {
        bookmarkModel.clear();
        message.visible = false;
        busyIndicator.running = true;
        refresh = false;
    }

    function formatTimestamp(timestamp) {
        return timestamp.substr(0, 10);
    }

    // "title":"Diigo API Help",
    // "url":"http://www.diigo.com/help/api.html",
    // "user":"foo",
    // "desc":"",
    // "tags":"test,diigo,help",
    // "shared":"yes",
    // "created_at":"2008/04/30 06:28:54 +0800",
    // "updated_at":"2008/04/30 06:28:54 +0800",
    // "comments":[],
    // "annotations":[]


    function showBookmarksCallback(bookmarks) {
        message.serviceError = false;
        bookmarkModel.clear();

        for (var i = 0; i < bookmarks.length; i++) {
            bookmarkModel.append(bookmarks[i]);
        }

        message.visible = bookmarkModel.count === 0;
    }

    function showBookmarksAfterAddCallback() {
        busyIndicator.running = false;
        refresh = true;
        preparePage();
    }

    function showErrorCallback(error) {
        console.error(error.detailMessage);
        bookmarkModel.clear();
        busyIndicator.running = false;
        message.serviceError = true;
        message.serviceResult = error;
        message.visible = true;
    }
}
