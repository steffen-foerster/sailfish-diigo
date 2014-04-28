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
import "../Settings.js" as Settings
import "../AppState.js" as AppState

/**
 * Service: Pinboard
 * Page to save user settings.
 */
Dialog {
    id: settingPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_ADD;
        }
    }

    onAccepted: {
        Settings.set(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS, recentBookmarks.value);
        Settings.set(getAppContext().service, Settings.keys.API_KEY, apiKey.text);

        getAppContext().state = AppState.T_SETTINGS_ACCEPTED;
    }

    onRejected: {
        getAppContext().state = AppState.T_SETTINGS_REJECTED;
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
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
                    getAppContext().state = AppState.T_CHANGE_SERVICE;
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
                title: qsTr("Settings")
            }

            Button {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                text: qsTr("Get your API Token")
                onClicked: {
                    Qt.openUrlExternally("https://pinboard.in/settings/password");
                }
            }

            Column {
                id: column

                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                spacing: Theme.paddingMedium

                TextField {
                    id: apiKey
                    placeholderText: qsTr("API Token")
                    label: qsTr("API Token")
                    width: parent.width
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: recentBookmarks.focus = true
                    text: Settings.get(getAppContext().service, Settings.keys.API_KEY)
                }

                Slider {
                    id: recentBookmarks
                    label: qsTrId("Recent bookmarks")
                    width: parent.width
                    minimumValue: 5
                    maximumValue: 50
                    stepSize: 5
                    valueText: value
                    value: Settings.get(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS)
                }
            }
        }

    }
}
