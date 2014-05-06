/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

I used the file
/usr/share/sailfish-browser/pages/ShareLinkPage.qml
from Antti Seppälä (Jolla Ldt.) as the template for this page.

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
//import Sailfish.TransferEngine 1.0

import "AppState.js" as AppState

/**
 * Import of Sailfish.TransferEngine 1.0 is not allowed (May 2014).
 *
 * Current list of allowed libraries:
 *   https://github.com/sailfish-sdk/sdk-harbour-rpmvalidator/blob/master/allowed_libraries.conf
 *
 * Sharing with Email shows no contact: See: https://together.jolla.com/question/12148
 */
Page {
    id: sharePage

    property variant url
    property string title

    onStatusChanged: {
        if (status === PageStatus.Active) {
            getAppContext().state = AppState.S_SHARE;
        }
    }
    /*
    ShareMethodList {
        id: list
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Share bookmark")
        }
        filter: "text/x-url"
        content: {
            "type": "text/x-url",
            "status": sharePage.url,
            "linkTitle": sharePage.title
        }

        ViewPlaceholder {
            enabled: list.model.count === 0
            text: qsTr("No sharing accounts available.")
        }
    }
    */
}
