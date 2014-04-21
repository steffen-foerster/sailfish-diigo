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
import "../pages/AppState.js" as AppState
import "../pages/Utils.js" as Utils
import "../pages"

CoverBackground {

    id: cover

    CoverPlaceholder {
        anchors.centerIn: parent
        text: qsTr("Add or search a bookmark")
    }

    Label {
        id: urlHint
        visible: hasUrlInClipboard()
        text: qsTr("URL in clipboard")
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }
    }
    Label {
        visible: urlHint.visible
        anchors {
            top: urlHint.bottom
            horizontalCenter: urlHint.horizontalCenter
        }
        text: startOfUrl()
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: addBookmark()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: search()
        }
    }

    function startOfUrl() {
        if (hasUrlInClipboard()) {
            var text = Clipboard.text;
            if (text.indexOf("https") === 0) {
                text = text.substring(8, text.length);
            }
            else {
                text = text.substring(7, text.length);
            }
            return Utils.crop(text, 18);
        }
        return "";
    }

    function hasUrlInClipboard() {
        if (Clipboard.hasText) {
            var urls = Clipboard.text.match(/^http[s]*:\/\/.{3,242}$/);
            if (urls.length > 0) {
                return true;
            }
        }
        return false;
    }

    function addBookmark () {
        var state = getAppContext().state;
        console.log("state: " + state);

        var performAdd = true;
        if (state === AppState.S_START) {
            performAdd = true;
        }
        else if (state === AppState.S_SETTINGS ||
                 state === AppState.S_ADD) {
            pageStack.currentPage.reject();
            performAdd = true;
        }

        if (performAdd) {
            pageStack.completeAnimation();

            getAppContext().state = AppState.T_START_ADD;
            pageStack.push(Qt.resolvedUrl("../pages/AddBookmarkPage.qml"));
            mainWindow.activate()
        }
    }

    function search () {

    }
}


