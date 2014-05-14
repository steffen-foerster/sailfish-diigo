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

/**
 * Service: Diigo
 * Page to save user settings for Diigo service.
 */
Dialog {
    id: settingPage

    onAccepted: {
        Settings.set(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS, recentBookmarks.value);
        Settings.setBoolean(getAppContext().service, Settings.keys.SAVE_PASSWORD, savePassword.checked);
        Settings.setPassword(password.text, savePassword.checked, getAppContext());
        Settings.set(getAppContext().service, Settings.keys.USER, user.text);
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset to defaults")
                onClicked: {
                    user.text = ""
                    password.text = ""
                    savePassword.checked = false
                    recentBookmarks.value = 10
                }
            }
            MenuItem {
                text: qsTr("Change service")
                onClicked: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("../ServicePage.qml"), {placeholderVisible: true});
                }
            }
        }

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                id: header
                acceptText: qsTr("Save")
                title: qsTr("Settings")
            }

            TextField {
                id: user
                placeholderText: qsTr("Username")
                label: qsTr("Username")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
                text: Settings.get(getAppContext().service, Settings.keys.USER)
            }

            TextField {
                id: password
                placeholderText: qsTr("Password")
                label: qsTr("Password")
                width: parent.width
                echoMode: TextInput.Password
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                text: Settings.getPassword(getAppContext())
            }

            Label {
                anchors {
                    right: header.right
                    rightMargin: Theme.paddingLarge
                }
                text: qsTr("Note: It's comfortable but not secure")
                width: parent.width
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignRight
            }

            TextSwitch {
                id: savePassword
                text: "Save password"
                description: "Save password on your phone"
                checked: Settings.getBoolean(getAppContext().service, Settings.keys.SAVE_PASSWORD)
            }

            Slider {
                id: recentBookmarks
                label: qsTrId("Recent bookmarks")
                width: parent.width
                minimumValue: 5
                maximumValue: 100
                stepSize: 5
                valueText: value
                value: Settings.get(getAppContext().service, Settings.keys.COUNT_RECENT_BOOKMARKS)
            }
        }
    }
}
