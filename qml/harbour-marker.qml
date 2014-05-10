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
    cover: null //Qt.resolvedUrl("cover/CoverPageInactive.qml")

    Component.onCompleted: {
        console.log("ApplicationWindow onCompleted");
        Settings.initialize();

        var activeServiceStr = Settings.get(Settings.services.ALL, Settings.keys.SERVICE);
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

}
