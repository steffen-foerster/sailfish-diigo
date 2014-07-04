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
import "../pages"

CoverBackground {

    id: cover

    CoverPlaceholder {
        anchors.centerIn: parent
        text: qsTr("Search or add with ") + getServiceManager().getServiceName()
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
        text: getFirstLettersOfUrl()
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: addBookmarkAction()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: searchAction()
        }
    }

    function addBookmarkAction () {
        var mainPage = navigateToMainPage();
        pageStack.completeAnimation();
        mainPage.add();
        window.activate();
    }

    function searchAction () {
        var mainPage = navigateToMainPage();
        pageStack.completeAnimation();
        mainPage.search();
        window.activate();
    }

    function navigateToMainPage() {
        if (pageStack.depth === 1) {
            var mainPage = pageStack.currentPage;
            mainPage.activateBookmarkView();
        }
        else {
            pageStack.clear();
            var page = pageStack.replace(getMainPage());
            page.initialize();
        }
        return pageStack.currentPage;
    }

    function getFirstLettersOfUrl() {
        if (hasUrlInClipboard()) {
            var text = Clipboard.text;
            if (text.indexOf("https") === 0) {
                text = text.substring(8, text.length);
            }
            else {
                text = text.substring(7, text.length);
            }
            return Utils.crop(text, 15) + "..";
        }
        return "";
    }

    function hasUrlInClipboard() {
        return Utils.getUrlFromClipboard(Clipboard.hasText, Clipboard.text) ? true : false;
    }

}


