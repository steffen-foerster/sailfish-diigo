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
import "DiigoService.js" as DiigoService
import "AppState.js" as AppState
import "Utils.js" as Utils

/**
 * Page to search bookmarks.
 */
Dialog {
    id: searchPage

    acceptDestination: Qt.resolvedUrl("SearchResultPage.qml")

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_SEARCH;
        }
    }

    onAccepted: {     
        var criteria = createCriteria();
        acceptDestinationInstance.criteria = criteria
    }

    onRejected: {
        getAppContext().state = AppState.T_SEARCH_REJECTED;
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            visible: menuClear.visible
            MenuItem {
                id: menuClear
                text: qsTr("Clear")
                onClicked: clearFields()
            }
        }

        contentHeight: column.height

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
                placeholderText: qsTr("Tags, comma separated")
                label: qsTr("Tags, comma separated")
                width: parent.width
                focus: true;
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: list.focus = true
            }
            TextField {
                id: list
                placeholderText: qsTr("List name")
                label: qsTr("List name")
                width: parent.width
                EnterKey.enabled: true
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: filter.focus = true
            }
            TextSwitch {
                id: filter
                text: qsTr("Public and private")
                description: qsTr("Show public and private bookmarks")
                checked: true
            }
            ComboBox {
                id: sort
                width: parent.width
                label: qsTr("Sort by")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Created at")
                    }
                    MenuItem {
                        text: qsTr("Updated at")
                    }
                    MenuItem {
                        text: qsTr("Popularity")
                    }
                }
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
        liste.text = "";
        filter.checked = true;
        sort.value = "0";
        sort.currentIndex = 0;
        count.value = 5;
    }

    function createCriteria() {
        var criteria = {
            tags: Utils.crop(tags.text, 250),
            list: Utils.crop(list.text, 250),
            filter: filter.checked,
            sort: sort.currentIndex,
            count: count.value
        }
        return criteria;
    }
}


