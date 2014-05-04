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
import "../Utils.js" as Utils

/**
 * Service: Diigo
 * Shows the details of a bookmark.
 */
Page {
    id: viewBookmarkPage

    property variant bookmark

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
                    console.log("opening URL: " + bookmark.url)
                    Qt.openUrlExternally(bookmark.url)
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
                text: bookmark.title
                separator: false
            }
            LabelText {
                label: qsTr("URL")
                text: bookmark.url
            }
            LabelText {
                label: qsTr("Description")
                text: bookmark.desc
            }
            LabelText {
                label: qsTr("Tags")
                text: formatTags(bookmark.tags)
            }
            LabelText {
                label: qsTr("Created at")
                text: Utils.formatTimestamp(bookmark.created_at)
                separator: false
            }
            LabelText {
                label: qsTr("Updated at")
                text: Utils.formatTimestamp(bookmark.updated_at)
                separator: false
            }
        }
        VerticalScrollDecorator {}
    }

    function formatTags(tags) {
        var retval = tags;
        if (tags) {
            retval = tags.replace(",", " ")
        }
        return retval;
    }

}
