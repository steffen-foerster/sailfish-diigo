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

/**
 * Page to edit a bookmark.
 */
Dialog {
    id: editPage

    property variant bookmark

    property variant oldBookmark

    function clearFields() {
        href.text = "";
        title.text = "";
        tags.text = "";
        desc.text = "";
        shared.checked = true;
        toread.checked = false;
    }

    function updateBookmark() {
        bookmark.href = Utils.crop(href.text, 250);
        bookmark.title = Utils.crop(title.text, 250);
        bookmark.tags = Utils.crop(tags.text, 250);
        bookmark.desc = Utils.crop(desc.text, 250);
        bookmark.shared = shared.checked ? "yes" : "no";
        bookmark.toread = toread.checked ? "yes" : "no"
    }

    canAccept: (!href.errorHighlight && !title.errorHighlight)

    onAccepted: {
        editPage.oldBookmark = Bookmark.copy(bookmark);
        updateBookmark();
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

            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                acceptText: qsTr("Save")
            }

            TextField {
                id: href
                text: bookmark.href
                placeholderText: qsTr("Enter URL")
                label: qsTr("Modified URL creates new bookmark")
                width: column.width
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /^http[s]*:\/\/.{3,242}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: title.focus = true
            }
            TextField {
                id: title
                text: bookmark.title
                placeholderText: qsTr("Title")
                label: qsTr("Title")
                focus: true
                width: column.width
                validator: RegExpValidator { regExp: /^.{3,250}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tags.focus = true
            }
            TextField {
                id: tags
                text: Utils.getBlankIfNull(bookmark.tags)
                placeholderText: qsTr("Tags, separated by space")
                label: qsTr("Tags, separated by space")
                width: column.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: desc.focus = true
            }
            TextField {
                id: desc
                text: Utils.getBlankIfNull(bookmark.desc)
                placeholderText: qsTr("Description")
                label: qsTr("Description")
                width: column.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
            TextSwitch {
                id: shared
                checked: (bookmark.shared === "yes")
                text: qsTr("Public")
                description: qsTr("Save the bookmark as public")
            }
            TextSwitch {
                id: toread
                checked: (bookmark.toread === "yes")
                text: qsTr("Read Later")
                description: qsTr("The bookmark is \"unread\"");
            }
        }
    }
}
