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
import "pages"
import "services"
import "js/Settings.js" as Settings
import "services/Services.js" as Services

ApplicationWindow
{
    id: window

    function setActiveCover() {
        window.cover = Qt.resolvedUrl("cover/CoverPageActive.qml")
    }

    function setInactiveCover() {
        window.cover = Qt.resolvedUrl("cover/CoverPageInactive.qml")
    }

    function getAppContext() {
        return appContext;
    }

    function isSignedIn() {
        return Settings.isSignedIn(appContext)
    }

    function getMainPage() {
        return mainPage;
    }

    function getSignInPage() {
        return signInPage;
    }

    function getServiceManager() {
        return serviceManager;
    }

    initialPage: Page{}
    cover: null

    Component.onCompleted: {
        console.log("ApplicationWindow onCompleted");
        Settings.initialize();

        var activeServiceStr = Settings.get(Services.ALL, Settings.keys.SERVICE);
        var activeService = parseInt(activeServiceStr);

        console.log("saved service: ", activeService);
        if (activeService > 0) {
            serviceManager.startService(activeService);
        }
        else {
            pageStack.replace(servicePage);
        }
    }

    QtObject {
        id: appContext
        property string password: ""
        property string state: ""
        property int service
        property string diigoApiKey: SailUtil.apiKey
    }

    Component {
        id: signInPage
        SignInPage { }
    }

    Component {
        id: servicePage
        ServicePage { }
    }

    Component {
        id: mainPage
        MainPage { }
    }

    ServiceManager {
        id: serviceManager
    }

    // Source: Written by Dickson Leong (Application: Tweetian) - thanks!
    Rectangle {
        id: infoPanel

        width: parent.width
        height: infoText.height + 2 * Theme.paddingMedium

        color: Theme.highlightBackgroundColor
        opacity: 0.0
        z: 10

        function showText(text) {
            infoText.text = text
            infoPanel.opacity = 0.9
            infoPanel.visible = true

            console.log("INFO: " + text)
            closeTimer.restart()
        }

        function showError(error) {
            var msg = error.errorMessage + "\n" + error.detailMessage;
            showText(msg);
        }

        Label {
            id: infoText
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingMedium
            x: Theme.paddingMedium
            width: parent.width - 2 * Theme.paddingMedium
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Behavior on opacity { FadeAnimation {} }
        Behavior on visible { FadeAnimation {} }

        Timer {
            id: closeTimer
            interval: 6000
            onTriggered: {
                infoPanel.opacity = 0.0
                infoPanel.visible = false
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                closeTimer.stop()
                infoPanel.opacity = 0.0
                infoPanel.visible = false
            }
        }
    }
}
