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
import "pages/Settings.js" as Settings
import "pages/AppState.js" as AppState

ApplicationWindow
{
    id: mainWindow
    initialPage: servicePage
    cover: Qt.resolvedUrl("cover/CoverPageInactive.qml")

    Component.onCompleted: {
        console.log("ApplicationWindow onCompleted");

        if (getAppContext().state === AppState.T_MAIN_START) {
            Settings.initialize()
        }

        var activeService = Settings.get(Settings.services.ALL, Settings.keys.SERVICE);
        console.log("saved service: ", activeService);
        if (activeService == Settings.services.DIIGO) {
            startService(Settings.services.DIIGO);
        }
        else if (activeService == Settings.services.PINBOARD) {
            startService(Settings.services.PINBOARD);
        }
        else {
            servicePage.placeholderVisible = true
        }
    }

    Component.onDestruction: {
    }

    QtObject {
        id: appContext
        property string password: ""
        property string apiKey: SailUtil.apiKey // API-Key for Diigo
        property string state: AppState.T_MAIN_START
        property variant dialogProperties
        property int service
    }

    Component {
        id: servicePage
        ServicePage { }
    }

    function setActiveCover() {
        mainWindow.cover = Qt.resolvedUrl("cover/CoverPageActive.qml")
    }

    function setInactiveCover() {
        mainWindow.cover = Qt.resolvedUrl("cover/CoverPageInactive.qml")
    }

    function startService(service) {
        console.log("start service: " + service);
        getAppContext().service = service;
        getAppContext().state = AppState.T_SERVICE_START;
        pageStack.replace(Qt.resolvedUrl(getFolderByService() + "StartPage.qml"));
    }

    function getAppContext() {
        return appContext;
    }

    function isSignedIn() {
        return Settings.isSignedIn(appContext)
    }

    function getFolderByService() {
        if (getAppContext().service === Settings.services.DIIGO) {
            return "pages/diigo/";
        }
        else if (getAppContext().service === Settings.services.PINBOARD) {
            return "pages/pinboard/";
        }
    }

    function getServiceName() {
        if (getAppContext().service === Settings.services.DIIGO) {
            return "DIIGO";
        }
        else if (getAppContext().service === Settings.services.PINBOARD) {
            return "PINBOARD";
        }
    }
}
