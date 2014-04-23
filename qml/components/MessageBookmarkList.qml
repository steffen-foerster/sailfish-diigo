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

Item {
    property int count: 0

    property bool signedIn: false

    property bool serviceError: false

    property variant serviceResult: undefined

    anchors.fill: parent

    onSignedInChanged: {
        computeText()
    }

    onServiceErrorChanged: {
        computeText()
    }

    onVisibleChanged: {
        computeText()
    }

    Label {
        id: messageFirstLine
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        text: ""
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
    }
    Label {
        id: messageSecondLine
        anchors {
            top: messageFirstLine.bottom
            horizontalCenter: messageFirstLine.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        text: ""
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
    }

    function computeText() {
        if (!signedIn) {
            messageFirstLine.text = qsTr("Not signed in");
            messageSecondLine.text = qsTr("Pull down to sign in");
        }
        else if (serviceError) {
            messageFirstLine.text = serviceResult.errorMessage;
            messageSecondLine.text = serviceResult.detailMessage;
        }
        else if (count === 0) {
            messageFirstLine.text = qsTr("No bookmarks found");
            messageSecondLine.text = "";
        }
        else {
            console.assert(false, "Undefined State, mode: " + mode);
        }
    }
}
