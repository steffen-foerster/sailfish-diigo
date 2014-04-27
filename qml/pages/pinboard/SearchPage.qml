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
 * Service: Pinboard
 * Page to search bookmarks.
 */
Dialog {
    id: searchPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_SEARCH;
        }
    }

    onAccepted: {     
        var startPage = pageStack.previousPage();
        var criteria = createCriteria();
        getAppContext().dialogProperties = criteria;
        getAppContext().state = AppState.T_SEARCH_ACCEPTED;
    }

    onRejected: {
        getAppContext().state = AppState.T_SEARCH_REJECTED;
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            visible: menuClear.visible
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
                acceptText: qsTr("Search")
            }

            TextField {
                id: tags
                placeholderText: qsTr("Tags, separated by space")
                label: qsTr("Tags, separated by space")
                width: parent.width
                focus: true;
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: description.focus = true
            }
            TextField {
                id: description
                placeholderText: qsTr("Title")
                label: qsTr("Title")
                width: parent.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: extended.focus = true
            }
            TextField {
                id: extended
                placeholderText: qsTr("Description")
                label: qsTr("Description")
                width: parent.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: count.focus = true
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

    function clearFields() {
        tags.text = "";
        description.text = "";
        extended.text = "";
        count.value = 5;
    }

    function createCriteria() {
        var criteria = {
            tags: tags.text,
            description: description.text,
            extended: extended.text,
            count: count.value
        }
        return criteria;
    }
}


