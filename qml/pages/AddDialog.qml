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
 * Page to add a new bookmark.
 */
Dialog {
    id: addPage

    property var bookmark: null

    function autofillUrl() {
        var url = Utils.getUrlFromClipboard(Clipboard.hasText, Clipboard.text);
        if (url) {
            href.text = url;
            title.focus = true;
        }
    }

    function clearFields() {
        href.text = "";
        title.text = "";
        tags.text = "";
        desc.text = "";
        shared.checked = true;
        toread.checked = false;
    }

    function createBookmark() {
        var bookmark = Bookmark.create(
            Utils.crop(href.text, 250),
            Utils.crop(title.text, 250),
            Utils.crop(desc.text, 250),
            Utils.crop(tags.text, 250),
            shared.checked ? "yes" : "no",
            toread.checked ? "yes" : "no"
        );
        return bookmark;
    }

    state: "ADD"

    onStatusChanged: {
        if (status === PageStatus.Active && state === "ADD") {
            autofillUrl();
        }
    }

    canAccept: (!href.errorHighlight && !title.errorHighlight)

    onAccepted: {
        addPage.bookmark = createBookmark();
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                id: menuClear
                text: qsTr("Clear fields")
                onClicked: clearFields()
            }
            MenuItem {
                id: menuImport
                text: qsTr("Import from default browser")
                onClicked: {
                    addPage.state = "IMPORT"
                    var importPage = pageStack.push("ImportPage.qml");
                    importPage.selected.connect(function(browserBookmark){
                        clearFields();
                        href.text = browserBookmark.href
                        title.text = browserBookmark.title
                    });
                }
            }
            MenuItem {
                id: menuScan
                text: qsTr("Scan QR code")
                onClicked: {
                    addPage.state = "SCAN"
                    var scanPage = pageStack.push("AutoScanPage.qml");
                    scanPage.scanned.connect(function(scannedUrl){
                        clearFields();
                        href.text = scannedUrl
                    });
                }
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
                EnterKey.onClicked: desc.focus = true
            }
            TextField {
                id: desc
                placeholderText: qsTr("Description")
                label: qsTr("Description")
                width: column.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
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

    states: [
        State {
            name: "ADD"
        },
        State {
            name: "IMPORT"
        },
        State {
            name: "SCAN"
        }
    ]
}


