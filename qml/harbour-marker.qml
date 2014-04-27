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
    initialPage: Component { ServicePage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Component.onCompleted: {
        console.log("ApplicationWindow onCompleted");

        if (getAppContext().state === AppState.T_MAIN_START) {
            Settings.initialize()
        }

        var activeService = Settings.get(Settings.services.ALL, Settings.keys.SERVICE);
        console.log("saved service: ", activeService);
        if (activeService == Settings.services.DIIGO) {
            //startDiigo()
        }
    }

    Component.onDestruction: {
    }

    function startDiigo() {
        console.log("startDiigo");
        getAppContext().service = Settings.services.DIIGO;
        getAppContext().state = AppState.T_DIIGO_START;
        pageStack.replace(Qt.resolvedUrl("pages/diigo/StartPage.qml"));
    }

    QtObject {
        id: appContext
        property string password: ""
        property string apiKey: SailUtil.apiKey // API-Key for Diigo
        property string state: AppState.T_MAIN_START
        property variant dialogProperties
        property int service
    }

    function getAppContext() {
        return appContext;
    }

    function isSignedIn() {
        return Settings.isSignedIn(appContext)
    }
}
