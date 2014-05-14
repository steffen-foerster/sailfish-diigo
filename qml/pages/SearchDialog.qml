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

/**
 * Page to search for bookmarks.
 */
Dialog {
    id: searchPage

    property variant criteria: null

    function clearFields() {
        tags.text = "";
        title.text = "";
        desc.text = "";
        count.value = 5;
    }

    function createCriteria() {
        var criteria = {
            tags: tags.text,
            title: title.text,
            desc: desc.text,
            count: count.value
        }
        return criteria;
    }

    onAccepted: {     
        console.log("SearchDialog.onAccepted");
        searchPage.criteria = createCriteria();
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
                acceptText: qsTr("Search")
            }

            TextField {
                id: tags
                placeholderText: qsTr("Tags, separated by space")
                label: qsTr("Tags, separated by space")
                width: parent.width
                focus: true;
                inputMethodHints: Qt.ImhNoAutoUppercase
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: title.focus = true
            }
            TextField {
                id: title
                placeholderText: qsTr("Title")
                label: qsTr("Title")
                width: parent.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: desc.focus = true
            }
            TextField {
                id: desc
                placeholderText: qsTr("Description")
                label: qsTr("Description")
                width: parent.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
            Slider {
                id: count
                label: qsTrId("Returned bookmarks")
                width: parent.width
                minimumValue: 5
                maximumValue: 50
                stepSize: 5
                valueText: value
                value: 20
            }
        }
    }
}


