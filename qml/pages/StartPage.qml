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

/**
 * Startpage shows the recentenly created Bookmarks.
 */
Page {
    id: page

    Component.onCompleted: {
        console.log("completedCallback");
        if (isSignedIn()) {
            console.log("signed in");
            DiigoService.getRecentBookmarks(
                        8, showBookmarksCallback, showErrorCallback, getApiKey());
        }
        else {
            console.log("not signed in");
        }
    }

    SilicaListView {
        id: bookmarkList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Add bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("Bookmark.qml"))
            }
            MenuItem {
                text: qsTr("Show recent bookmarks")
                onClicked: DiigoService.getRecentBookmarks(
                               2, showBookmarksCallback, showErrorCallback, getApiKey())
            }
            MenuItem {
                text: qsTr("Sign in / Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingPage.qml"));
            }
        }

        header: PageHeader {
            title: qsTr("Your recent bookmarks")
        }

        Item {
            id: message
            anchors.fill: parent
            visible: bookmarkModel.count == 0

            Label {
                id: messageFirstLine
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                text: "Maybe not signed in"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }
            Label {
                anchors {
                    top: messageFirstLine.bottom
                    horizontalCenter: messageFirstLine.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                text: "Pull down to sign in"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        width: page.width
        spacing: Theme.paddingLarge
        model: ListModel {
            id: bookmarkModel
        }
        delegate: ListItem {
            id: wrapper
            contentHeight: itemColumn.height
            property string url: url

            onClicked: {
                console.log("opening URL: " + wrapper.url)
                Qt.openUrlExternally(wrapper.url)
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
        bookmarkModel.clear();

        for (var i = 0; i < bookmarks.length; i++) {
            bookmarkModel.append(bookmarks[i]);
        }

        /*
        var component = Qt.createComponent("../components/BookmarkItem.qml");
        if (component.status === Component.Ready) {
            for (var i = 0; i < bookmarks.length; i++) {
                var item = component.createObject(column);
                item.title = bookmarks[i].title;
                item.url = bookmarks[i].url;
                item.width = column.width
            }
        }
        else {
            console.log("Error loading component:", component.errorString());
        }
        */
    }

    function showErrorCallback(error) {
        console.error(error.message);
    }

}
