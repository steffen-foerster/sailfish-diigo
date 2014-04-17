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

/**
 * Page to a bookmark to Diigo.
 */
Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
            MenuItem {
                text: qsTr("Clear")
                onClicked: {
                    bookmark.text = ""
                    tags.text = ""
                    privaty.checked = false
                }
                visible: anyFieldChanged()
            }
            MenuItem {
                text: qsTr("Save bookmark")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
                visible: bookmark.text.length > 0
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Add Bookmark")
            }
            Label {
                text: Util.getApiKey()
                width: column.width
            }

            TextField {
                id: bookmark
                placeholderText: qsTr("Enter or paste bookmark")
                label: qsTr("Bookmark")
                width: column.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tags.focus = true
            }
            TextField {
                id: tags
                placeholderText: qsTr("Enter your tags")
                label: qsTr("Tags")
                width: column.width
            }
            TextSwitch {
                id: privaty
                text: "Private"
                description: "Save the bookmark as private"
                onCheckedChanged: {
                    //
                }
            }
        }
    }

    /**
     * Returns true if any input field has not the default value.
     */
    function anyFieldChanged() {
        return bookmark.text.length > 0
                || tags.text.length > 0
                || privaty.checked;
    }
}


