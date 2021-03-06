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

import "../js/Settings.js" as Settings

/**
 * Page is shown if the user is not signed in.
 */
Page {
    id: signInPage

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (isSignedIn()) {
                var page = pageStack.replace(getMainPage());
                page.initialize();
            }
            else {
                setInactiveCover();
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width

        PullDownMenu {
            MenuItem {
                text: qsTr("Change service")
                onClicked: {
                    pageStack.clear();
                    pageStack.push(Qt.resolvedUrl("ServicePage.qml"));
                }
            }
            MenuItem {
                text: qsTr("Sign in / Settings")
                onClicked: {
                    pageStack.push(getServiceManager().getSettingsDialog());
                }
            }
        }

        PageHeader {
            title: qsTr("Sign in")
        }

        ViewPlaceholder {
            id: placeHolder
            enabled: true
            text: qsTr("Pull down to sign in to\n") + getServiceManager().getServiceName()
        }
    }
}
