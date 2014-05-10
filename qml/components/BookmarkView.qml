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

import "../js/Bookmark.js" as Bookmark
import "../js/Utils.js" as Utils

Item {
    id: root

    property string pageHeader: qsTr("Your recent bookmarks")

    function add() {
        var dialog = pageStack.push("../pages/AddDialog.qml");
        dialog.accepted.connect(function(){
            acceptAddCallback(dialog);
        });
    }

    function search() {
        var dialog = pageStack.push("../pages/SearchDialog.qml");
        dialog.accepted.connect(function(){
            acceptSearchCallback(dialog);
        });
    }

    function refresh() {
        console.log("refresh");

        bookmarkModel.clear();
        busyIndicator.running = true;

        getServiceManager().refresh(fetchRecentBookmarks, serviceErrorCallback);
    }

    function fetchRecentBookmarks() {
        console.log("fetchRecentBookmarks");

        pageHeader = qsTr("Your recent bookmarks")
        bookmarkModel.clear();
        busyIndicator.running = true;

        getServiceManager().fetchRecentBookmarks(fetchBookmarksCallback, serviceErrorCallback);
    }

    function fetchBookmarksCallback(bookmarks) {
        console.log("fetchBookmarksCallback");

        busyIndicator.running = false;

        for (var i = 0; i < bookmarks.length; i++) {
            bookmarkModel.append(bookmarks[i]);
        }
    }

    function acceptSettingsCallback(dialog) {
        console.log("settings accepted" + dialog);

        if (isSignedIn()) {
            fetchRecentBookmarks();
        }
        else {
            pageStack.replace(getSignInPage());
        }
    }

    function acceptSearchCallback(dialog) {
        console.log("search accepted: " + dialog);

        pageHeader = qsTr("Search result");
        bookmarkModel.clear();
        busyIndicator.running = true;

        getServiceManager().fetchBookmarks(dialog.criteria,
                                           fetchBookmarksCallback,
                                           serviceErrorCallback);
    }

    function acceptAddCallback(dialog) {
        console.log("add accepted: " + dialog);

        busyIndicator.running = true;

        getServiceManager().addBookmark(dialog.bookmark,
                                        fetchRecentBookmarks,
                                        serviceErrorCallback);
    }

    function serviceErrorCallback(error) {
        console.log("serviceErrorCallback");
        console.error(error.detailMessage);

        bookmarkModel.clear();
        busyIndicator.running = false;

        // TODO show error
    }

    height: mainView.height; width: mainView.width

    Item {
        id: busyIndicator

        property alias running: busyIndicator.visible

        anchors.fill: parent
        visible: false
        z: 1000

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }

        BusyIndicator {
            visible: busyIndicator.visible
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
    }

    SilicaListView {
        id: bookmarkList

        property Item contextMenu

        anchors.fill: parent
        width: parent.width
        spacing: Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    var dialog = pageStack.push(getServiceManager().getSettingsDialog());
                    dialog.accepted.connect(function(){
                        acceptSettingsCallback(dialog);
                    });
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    refresh();
                }
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: {
                    search();
                }
            }
            MenuItem {
                text: qsTr("Add or import bookmark")
                onClicked: {
                    add();
                }
            }
        }

        header: PageHeader {
            title: pageHeader
        }

        model: ListModel {
            id: bookmarkModel
        }

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
                pageStack.push(Qt.resolvedUrl("../pages/DetailsPage.qml"),
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
                    id: lbTitle
                    anchors {
                        left: parent.left
                        margins: Theme.paddingLarge
                    }
                    color: Theme.primaryColor
                    font {
                        pixelSize: Theme.fontSizeSmall
                        bold: model.toread === 'yes'
                    }
                    wrapMode: Text.Wrap
                    text: model.title
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
                    text: qsTr("Open in browser")
                    onClicked: {
                        console.log("opening URL: " + bookmarkModel.get(index).href)
                        Qt.openUrlExternally(bookmarkModel.get(index).href)
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    onClicked: {
                        remorse.execute(bookmarkList.contextMenu.parent,
                                        "Deleting",
                                        getDeleteFunction(bookmarkModel, index),
                                        3000)
                    }
                }
                MenuItem {
                    text: qsTr("Copy URL to clipboard")
                    onClicked: {
                        Clipboard.text = bookmarkModel.get(index).href
                    }
                }

                function getDeleteFunction(model, index) {
                    // Removing from list destroys the ListElement so we need a copy
                    var itemToDelete = Bookmark.copy(model.get(index));
                    var f = function() {
                        model.remove(index);
                        getServiceManager().deleteBookmark(itemToDelete, function() {},
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

        ViewPlaceholder {
            id: placeHolder
            enabled: bookmarkModel.count === 0 && !busyIndicator.enabled
            text: qsTr("No bookmarks found")
        }
    }

}
