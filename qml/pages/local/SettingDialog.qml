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

import "../../js/Settings.js" as Settings
import "../../js/Utils.js" as Utils

/**
 * Page to save user settings for Local service.
 */
Dialog {
    id: settingPage

    onAccepted: {
        Settings.set(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS, recentBookmarks.value);
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../AboutPage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Reset to defaults")
                onClicked: {
                    apiKey.text = ""
                    recentBookmarks.value = 10
                }
            }
            MenuItem {
                text: qsTr("Change service")
                onClicked: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("../ServicePage.qml"));
                }
            }
        }

        Column {
            spacing: Theme.paddingMedium
            width: parent.width

            DialogHeader {
                id: header
                acceptText: qsTr("Save")
            }

            Column {
                id: column

                width: parent.width
                spacing: Theme.paddingMedium

                Slider {
                    id: recentBookmarks
                    label: qsTrId("Recent bookmarks")
                    width: parent.width
                    minimumValue: 5
                    maximumValue: 100
                    stepSize: 5
                    valueText: value
                    value: Utils.getZeroIfNull(Settings.get(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS))
                }
            }
        }

    }
}
