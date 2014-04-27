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

import "Settings.js" as Settings
import "AppState.js" as AppState

/**
 * Page to select the provider.
 */
Page {
    id: providerPage

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("Diigo")
                onClicked: {
                    Settings.set(Settings.services.ALL, Settings.keys.SERVICE, Settings.services.DIIGO);
                    getAppContext().service = Settings.services.DIIGO;
                    getAppContext().state = AppState.T_DIIGO_START;
                    pageStack.replace(Qt.resolvedUrl("diigo/StartPage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Pinboard")
                onClicked: {
                    getAppContext().service = Settings.services.PINBOARD;
                    getAppContext().state = AppState.T_PINBOARD_START;
                    //pageStack.push(Qt.resolvedUrl("AddBookmarkPage.qml"))
                }
            }
        }

        PageHeader {
            title: qsTr("Start")
        }

        ViewPlaceholder {
            enabled: true
            text: qsTr("Pull down to select your service")
        }
    }
}

