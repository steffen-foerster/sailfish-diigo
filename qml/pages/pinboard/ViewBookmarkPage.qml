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
import "../Settings.js" as Settings
import "../AppState.js" as AppState
import "PinboardService.js" as PinboardService
import "../Utils.js" as Utils

/**
 * Service: Pinboard
 * Shows the details of a bookmark.
 */
Page {

    property variant bookmark

    id: viewBookmarkPage

    onStatusChanged: {
        if (status === Component.Loading) {
            getAppContext().state = AppState.S_VIEW_BOOKMARK;
        }
        if (status === PageStatus.Deactivating) {
            getAppContext().state = AppState.T_VIEW_BOOKMARK_START;
        }
    }

    SilicaFlickable {
        id: bookmarkList
        anchors.fill: parent
        contentHeight: itemColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Open in browser")
                onClicked: {
                    console.log("opening URL: " + bookmark.href)
                    Qt.openUrlExternally(bookmark.href)
                }
            }
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    getAppContext().state = AppState.T_VIEW_BOOKMARK_EDIT;
                    pageStack.push(Qt.resolvedUrl("EditBookmarkPage.qml"), {bookmark: bookmark, viewPage: viewBookmarkPage})
                }
            }
            MenuItem {
                text: (bookmark.toread === 'yes' ? qsTr("Mark as read") : qsTr("Mark as to read"))
                onClicked: {
                    bookmark.toread = (bookmark.toread === 'yes' ? 'no' : 'yes')
                    // TODO add failure handler
                    PinboardService.updateBookmark(bookmark, function(){},
                        function() {
                            // failure -> reverse flag
                            bookmark.toread = (bookmark.toread === 'yes' ? 'no' : 'yes')
                        }
                    )
                }
            }
        }

        Column {
            id: itemColumn
            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            height: childrenRect.height + 2 * Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                title: qsTr("Bookmark")

                Image {
                    anchors {
                        top: header.bottom
                        right: header.right
                    }
                    height: Theme.iconSizeMedium * 0.8
                    fillMode: Image.PreserveAspectFit
                    source: "image://theme/icon-m-device-lock"
                    visible: bookmark.shared === 'no'
                }
            }

            LabelText {
                label: qsTr("Title")
                text: bookmark.description
                font.bold: bookmark.toread === 'yes'
                separator: false
            }
            LabelText {
                label: qsTr("URL")
                text: bookmark.href
            }
            LabelText {
                label: qsTr("Description")
                text: bookmark.extended
            }
            LabelText {
                label: qsTr("Tags")
                text: bookmark.tags
            }
            LabelText {
                label: qsTr("Created at")
                text: Utils.formatTimestamp(bookmark.time)
                separator: false
            }
        }
        VerticalScrollDecorator {}
    }

    function editSuccessCallback() {
        getAppContext().state = AppState.S_VIEW_BOOKMARK;
    }

    function editFailureCallback(errorResult, oldBookmark) {
        getAppContext().state = AppState.S_VIEW_BOOKMARK;
        // restore bookmark values
        bookmark.href = oldBookmark.href;
        bookmark.description = oldBookmark.description;
        bookmark.tags = oldBookmark.tags;
        bookmark.extended = oldBookmark.extended;
        bookmark.shared = oldBookmark.shared;
        bookmark.toread = oldBookmark.toread;
        // TODO show error message
    }
}
