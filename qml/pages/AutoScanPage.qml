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

import QtQuick 2.1
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.marker.AutoBarcodeScanner 1.0

import "../js/Settings.js" as Settings

Page {
    id: scanPage

    signal scanned(variant result)

    property variant scanner
    property Item viewFinder
    property variant beep

    property bool settingsInitialized: false

    property int seconds
    property int scanDuration: 20

    property int viewFinder_x: scanPage.width / 6
    property int viewFinder_y: Theme.paddingLarge * 2
    property int viewFinder_width: scanPage.width * (2/3)
    property int viewFinder_height: viewFinder_width * (4/3)

    function createScanner() {
        if (scanner) {
            console.log("scanner has been already created ...")
            return
        }

        console.log("creating scanner and viewfinder ...")
        scanner = scannerComponent.createObject(scanPage)
        scanner.setViewFinderRect(viewFinder_x, viewFinder_y, viewFinder_width, viewFinder_height)
        viewFinder = viewFinderComponent.createObject(parentViewFinder)
        viewFinder.source = scanner

        scanPage.state = "READY"
        scanner.startCamera()
    }

    function destroyScanner() {
        if (!scanner) {
            console.log("scanner has been already destroyed ...")
            return
        }

        console.log("destroying scanner and viewfinder ...")
        viewFinder.destroy()
        scanner.destroy()
        scanner = null

        scanPage.state = "INACTIVE"
    }

    function startScan() {
        seconds = scanDuration
        scanPage.state = "SCANNING"
        scanner.startScanning(scanDuration * 1000)
    }

    state: "INACTIVE"

    onStatusChanged: {
        if (scanPage.status === PageStatus.Active) {
            console.log("Page is ACTIVE")

            createScanner()
        }
        else if (scanPage.status === PageStatus.Inactive) {
            console.log("Page is INACTIVE")
            // stop scanning if page is not active
            destroyScanner()
        }
    }

    Timer {
        id: labelUpdateTimer
        interval: 1000;
        repeat: true
        onTriggered: {
            seconds --
            statusText.text = qsTr("Scan in progress for %1 seconds!").arg(seconds)
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active && scanPage.status === PageStatus.Active) {
                console.log("application state changed to ACTIVE and AutoScanPage is active")
                createScanner()
            }
            else if (!Qt.application.active) {
                console.log("application state changed to INACTIVE")
                // if the application is deactivated we have to stop the camera and destroy the scanner object
                // because of power consumption issues and impact to the camera application
                destroyScanner()
            }
        }
    }

    Component {
        id: scannerComponent

        AutoBarcodeScanner {

            onCameraStarted: {
                console.log("camera is started")
            }

            onDecodingFinished: {
                console.log("decoding finished, code: ", code)
                statusText.text = ""
                if (scanPage.state !== "ABORT") {
                    if (code.length > 0) {
                        pageStack.navigateBack()
                        scanned(code)
                    }
                    else {
                        statusText.text = qsTr("No code detected! Try again.")
                    }
                }
                scanPage.state = "READY"
            }

            onError: {
                console.log("scanning failed: ", errorCode)
                if (errorCode === BarcodeScanner.JollaCameraRunning) {
                    statusText.text = qsTr("Please close the Jolla Camera app.")
                    scanPage.state = "JOLLA_CAMERA"
                }
                else {
                    statusText.text = qsTr("Scanning failed (code: %1)! Try again.").arg(errorCode)
                    scanPage.state = "READY"
                }
            }
        }
    }

    Component {
        id: viewFinderComponent

        VideoOutput {
            anchors.fill: parent
            focus : visible // to receive focus when visible
            fillMode: VideoOutput.PreserveAspectFit
            orientation: -90
        }    
    }

    SilicaFlickable {
        id: scanPageFlickable
        anchors.fill: parent
        contentHeight: flickableColumn.height

        PullDownMenu {
            id: menu
            MenuItem {
                text: qsTr("About CodeReader")
                onClicked: {
                    pageStack.push("AboutPage.qml");
                    pageStack.push("SettingsPage.qml");
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    pageStack.push("SettingsPage.qml");
                }
            }
        }

        Column {
            id: flickableColumn
            width: parent.width
            spacing: Theme.paddingLarge

            anchors {
                top: parent.top
                topMargin: Theme.paddingLarge * 2
            }

            Item {
                id: parentViewFinder

                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 2/3
                height: ((parent.width * 2/3) / 3) * 4
            }

            Row {
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter

                Slider {
                    id: zoomSlider
                    width: parent.width
                    minimumValue: 1.0
                    maximumValue: 7.0
                    value: 3
                    stepSize: 1
                    onValueChanged: {
                        scanner.zoomTo(value)
                    }
                }
            }

            Text {
                id: statusText
                text: ""
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.Center
                color: Theme.highlightColor
            }

            BackgroundItem {
                id: clickableResult
                contentHeight: rowResult.height
                height: contentHeight
                width: scanPageFlickable.width
                anchors {
                    left: parent.left
                }
                enabled: false

                Row {
                    id: rowResult
                    width: parent.width - 2 * Theme.paddingLarge
                    height: Math.max(clipboardImg.contentHeight, resultText.contentHeight)
                    spacing: Theme.paddingLarge
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingLarge
                    }

                    Image {
                        id: clipboardImg
                        source: "image://theme/icon-m-clipboard"
                        visible: resultText.text.length > 0
                        anchors {
                            leftMargin: Theme.paddingLarge
                        }
                    }

                    Label {
                        id: resultText
                        anchors {
                            leftMargin: Theme.paddingLarge
                            top: clipboardImg.top
                        }
                        color: clickableResult.highlighted || !clickableResult.enabled
                               ? Theme.highlightColor
                               : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        font.underline: clickableResult.enabled
                        truncationMode: TruncationMode.Fade
                        width: parent.width - clipboardImg.width - 2 * Theme.paddingLarge
                        text: ""
                    }
                }

                onClicked: {
                    openInDefaultBrowser(resultText.text);
                }
            }
        }
    }

    VerticalScrollDecorator { flickable: scanPageFlickable }

    Rectangle {
        width: parent.width
        height: actionButton.height + Theme.paddingLarge * 2
        anchors {
            bottom: parent.bottom
        }
        z: 10
        color: "black"

        Button {
            id: actionButton
            anchors {
                centerIn: parent
            }
            z: 11
            onClicked: {
                if (scanPage.state === "READY") {
                    startScan()
                }
                else if (scanPage.state === "SCANNING") {
                    scanPage.state = "ABORT"
                    scanner.stopScanning()
                }
            }
            text: ""
        }
    }

    states: [
        State {
            name: "INACTIVE"
            PropertyChanges {target: labelUpdateTimer; running: false; restoreEntryValues: false}
            PropertyChanges {target: statusText; text: ""; restoreEntryValues: false}
        },
        State {
            name: "READY"
            PropertyChanges {target: labelUpdateTimer; running: false; restoreEntryValues: false}
            PropertyChanges {target: actionButton; text: qsTr("Scan"); restoreEntryValues: false}
        },
        State {
            name: "SCANNING"
            PropertyChanges {target: labelUpdateTimer; running: true; restoreEntryValues: false}
            PropertyChanges {target: statusText; text: qsTr("Scan in progress for %1 seconds!").arg(seconds); restoreEntryValues: false}
            PropertyChanges {target: resultText; text: ""; restoreEntryValues: false}
            PropertyChanges {target: clickableResult; enabled: false; restoreEntryValues: false}
            PropertyChanges {target: actionButton; text: qsTr("Abort"); restoreEntryValues: false}
        },
        State {
            name: "JOLLA_CAMERA"
            PropertyChanges {target: actionButton; enabled: false; restoreEntryValues: true}
            PropertyChanges {target: zoomSlider; enabled: false; restoreEntryValues: true}
            PropertyChanges {target: resultText; text: ""; restoreEntryValues: false}
        },
        State {
            name: "ABORT"
        }

    ]
}
