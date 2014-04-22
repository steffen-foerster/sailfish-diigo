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
 * Startpage shows the searched bookmarks.
 */
Page {
    id: searchResultPage

    property variant criteria

    onStatusChanged: {
        if (status === PageStatus.Active) {
            busyIndicator.running = true;
            getAppContext().state = AppState.S_SEARCH_WAIT_SERVICE;

            DiigoService.fetchBookmarks(criteria,
                                     successCallback,
                                     serviceErrorCallback,
                                     getAppContext())
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

        header: PageHeader {
            title: qsTr("Search result")
        }

        MessageBookmarkList {
            id: message
            visible: false;
            count: bookmarkModel.count
            mode: "RESULT_PAGE"
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

    function formatTimestamp(timestamp) {
        return timestamp.substr(0, 10);
    }

    // ---------------------------------------------------------
    // callbacks
    // ---------------------------------------------------------

    function successCallback(bookmarks) {
        busyIndicator.running = false;

        for (var i = 0; i < bookmarks.length; i++) {
            bookmarkModel.append(bookmarks[i]);
        }

        message.visible = bookmarkModel.count === 0;
        getAppContext().state = AppState.S_SEARCH_RESULT;
    }

    function serviceErrorCallback(error) {
        console.error(error.detailMessage);
        busyIndicator.running = false;
        message.serviceError = true;
        message.serviceResult = error;
        message.visible = true;
        getAppContext().state = AppState.S_SEARCH_RESULT;
    }

}
