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

Page {
    id: mainPage

    function initialize() {
        setActiveCover();
        bookmarksView.fetched.connect(tagsView.loadTags);
        tagsView.tagsSelected.connect(mainPage.searchByTags);

        bookmarksView.initialize();
        tagsView.initialize();
    }

    function activateBookmarkView() {
        mainView.currentIndex = 0
    }

    function add() {
        bookmarksView.add();
    }

    function search() {
        bookmarksView.search();
    }

    function searchByTags(tags) {
        activateBookmarkView();
        bookmarksView.searchByTags(tags);
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            bookmarksView.state = getServiceManager().getServiceName();
        }
    }

    SlideshowView {
        id: mainView

        itemWidth: width
        itemHeight: height
        height: window.height - (viewIndicator.height + tabHeader.childrenRect.height)
        clip:true

        anchors { top: parent.top; left: parent.left; right: parent.right }
        model: VisualItemModel {
            BookmarkView {id: bookmarksView}
            TagsView { id: tagsView }
        }
    }


    Rectangle {
        id: viewIndicator
        anchors.top: mainView.bottom
        color: Theme.highlightColor
        height: Theme.paddingMedium
        width: mainView.width / mainView.count
        x: mainView.currentIndex * width
        z: 2

        Behavior on x {
            NumberAnimation {
                duration: 200
            }
        }
    }

    Rectangle {
        anchors.top: mainView.bottom
        color: "black"
        opacity: 0.5
        height: Theme.paddingMedium
        width: mainView.width
        z: 1
    }

    Row {
        id: tabHeader
        anchors.top: viewIndicator.bottom

        Repeater {
            model: [qsTr("Bookmarks"), qsTr("Tags")]
            Rectangle {
                color: "black"
                height: Theme.paddingLarge * 2
                width: mainView.width / mainView.count

                Label {
                    anchors.centerIn: parent
                    text: modelData
                    color: Theme.highlightColor
                    font {
                        bold: true
                        pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }
        }
    }
}
