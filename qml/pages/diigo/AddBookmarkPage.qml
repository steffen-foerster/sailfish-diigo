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

/**
 * Service: Diigo
 * Page to add a bookmark.
 */
Dialog {
    id: addPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_ADD;
            autofillUrl();
        }
    }

    canAccept: (!url.errorHighlight && !title.errorHighlight)

    onAccepted: {
        var startPage = pageStack.previousPage();
        var bookmark = createBookmarkObj();
        getAppContext().dialogProperties = bookmark;
        getAppContext().state = AppState.T_ADD_ACCEPTED;
    }

    onRejected: {
        getAppContext().state = AppState.T_ADD_REJECTED;
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
                title: qsTr("Add bookmark")
            }

            TextField {
                id: url
                placeholderText: qsTr("Enter URL")
                label: qsTr("URL")
                width: column.width
                focus: true
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /^http[s]*:\/\/.{3,242}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: title.focus = true
            }
            TextField {
                id: title
                placeholderText: qsTr("Title")
                label: qsTr("Title")
                width: column.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /^.{3,250}$/ }
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tags.focus = true
            }
            TextField {
                id: tags
                placeholderText: qsTr("Tags, comma-separated")
                label: qsTr("Tags, comma-separated")
                width: column.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: description.focus = true
            }
            TextField {
                id: description
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
                id: readLater
                text: qsTr("Read Later")
                description: qsTr("The bookmark is \"unread\"");
                checked: false
            }
        }
    }

    function autofillUrl() {
        if (Clipboard.hasText) {
            var urls = Clipboard.text.match(/^http[s]*:\/\/.{3,242}$/);
            if (urls.length > 0) {
                url.text = urls[0];
                title.focus = true;
            }
        }
    }

    function clearFields() {
        url.text = "";
        title.text = "";
        tags.text = "";
        description.text = "";
        shared.checked = true;
        readLater.checked = false;
    }

    function createBookmarkObj() {
        var bookmark = {
            url: Utils.crop(url.text, 250),
            title: Utils.crop(title.text, 250),
            tags: Utils.crop(tags.text, 250),
            desc: Utils.crop(description.text, 250),
            shared: shared.checked,
            readLater: readLater.checked
        }
        return bookmark;
    }
}


