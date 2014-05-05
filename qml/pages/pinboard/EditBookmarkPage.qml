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
import "../AppState.js" as AppState
import "../Utils.js" as Utils
import "PinboardService.js" as PinboardService

/**
 * Service: Pinboard
 * Page to edit a bookmark.
 */
Dialog {

    property variant bookmark

    property variant viewPage

    id: editPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_EDIT;
            setValues();
        }
    }

    canAccept: (!href.errorHighlight && !description.errorHighlight)

    onAccepted: {
        var startPage = pageStack.previousPage();
        var bookmarkOld = copyBookmark();
        updateBookmarkObj();
        getAppContext().state = AppState.T_EDIT_ACCEPTED;
        PinboardService.updateBookmark(bookmark, viewPage.editSuccessCallback,
               function(errorResult) {
                   viewPage.editFailureCallback(errorResult, bookmarkOld)
               }
        );
    }

    onRejected: {
        getAppContext().state = AppState.T_EDIT_REJECTED;
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                id: menuClear
                text: qsTr("Clear")
                onClicked: clearFields()
            }
        }

        Column {
            id: column

            x: Theme.paddingLarge
            width: parent.width - 2 * Theme.paddingLarge
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Save")
                title: qsTr("Edit bookmark")
            }

            TextField {
                id: href
                placeholderText: qsTr("Enter URL")
                label: qsTr("Modified URL creates new bookmark")
                width: column.width
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /^http[s]*:\/\/.{3,242}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: description.focus = true
            }
            TextField {
                id: description
                placeholderText: qsTr("Title")
                label: qsTr("Title")
                focus: true
                width: column.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /^.{3,250}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tags.focus = true
            }
            TextField {
                id: tags
                placeholderText: qsTr("Tags, separated by space")
                label: qsTr("Tags, separated by space")
                width: column.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: extended.focus = true
            }
            TextField {
                id: extended
                placeholderText: qsTr("Description")
                label: qsTr("Description")
                width: column.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: shared.focus = true
            }
            TextSwitch {
                id: shared
                text: qsTr("Public")
                description: qsTr("Save the bookmark as public")
                checked: true
            }
            TextSwitch {
                id: toread
                text: qsTr("Read Later")
                description: qsTr("The bookmark is \"unread\"");
                checked: false
            }
        }
    }

    function clearFields() {
        href.text = "";
        description.text = "";
        tags.text = "";
        extended.text = "";
        shared.checked = true;
        toread.checked = false;
    }

    function setValues() {
        href.text = bookmark.href;
        description.text = bookmark.description;
        tags.text = bookmark.tags;
        extended.text = bookmark.extended;
        shared.checked = bookmark.shared === "yes";
        toread.checked = bookmark.toread === "yes";
    }

    function updateBookmarkObj() {
        bookmark.href = Utils.crop(href.text, 250);
        bookmark.description = Utils.crop(description.text, 250);
        bookmark.tags = Utils.crop(tags.text, 250 * 100);
        bookmark.extended = Utils.crop(extended.text, 65536);
        bookmark.shared = shared.checked ? "yes" : "no";
        bookmark.toread = toread.checked ? "yes" : "no"
    }

    function copyBookmark() {
        var copy = {
            href: bookmark.href,
            description: bookmark.description,
            tags: bookmark.tags,
            extended: bookmark.extended,
            shared: bookmark.shared,
            toread: bookmark.toread
        }
        return copy;
    }
}


