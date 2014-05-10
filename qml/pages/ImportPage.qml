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

import "../js/Utils.js" as Utils
import "../js/Bookmark.js" as Bookmark
import "../services/Importer.js" as Importer

Page {
    id: importPage

    signal selected(variant bookmark)

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var bookmarks = Importer.importBrowserBookmarks(SailUtil.getBrowserBookmarks)
            for (var i = 0; i < bookmarks.length; i++) {
                bookmarkModel.append(bookmarks[i]);
            }
        }
    }

    SilicaListView {
        id: bookmarkList

        anchors.fill: parent
        width: parent.width
        spacing: Theme.paddingLarge

        header: PageHeader {
            title: qsTr("Select bookmark")
        }

        model: ListModel {
            id: bookmarkModel
        }

        delegate: ListItem {
            id: wrapper

            function getTitle() {
                var title = model.title;
                if (!title || title.length === 0) {
                    title = model.href;
                }
                return title;
            }

            contentHeight: itemColumn.height

            onClicked: {
                pageStack.navigateBack();
                selected(bookmarkModel.get(index));
            }

            Column {
                id: itemColumn
                Label {
                    id: lbTitle
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    color: Theme.primaryColor
                    font {
                        pixelSize: Theme.fontSizeSmall
                    }
                    wrapMode: Text.Wrap
                    text: getTitle()
                    width: wrapper.ListView.view.width - (2 * Theme.paddingLarge)
                }
            }
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: bookmarkModel.count === 0
            text: qsTr("No bookmarks found")
        }
    }

}
