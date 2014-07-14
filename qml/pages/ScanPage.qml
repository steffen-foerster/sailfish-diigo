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
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import harbour.marker.BarcodeScanner 1.0

// TODO Add error handling code (camera is busy, cature failed, save failed)
Page {
    id: scanPage

    signal scanned(variant url)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("Scan QR code")
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 2/3
                height: ((parent.width * 2/3) / 3) * 4

                BarcodeScanner {
                    id: scanner

                    onDecodingFinished: {
                        console.log("decoding finished, code: ", code)
                        if (code.length > 0) {
                            pageStack.navigateBack();
                            scanPage.scanned(code);
                        }
                        else {
                            statusText.text = qsTr("No code detected! Try again.")
                        }
                        busyIndicator.running = false
                    }
                }

                VideoOutput {
                    id: viewFinder
                    source: scanner
                    anchors.fill: parent
                    focus : visible // to receive focus and capture key events when visible
                    fillMode: VideoOutput.PreserveAspectFit
                    orientation: -90

                    MouseArea {
                        anchors.fill: parent;
                        onClicked: {
                            busyIndicator.running = true
                            scanner.startScanning()
                        }
                    }
                }

                Rectangle {
                    anchors {
                        horizontalCenter: viewFinder.horizontalCenter
                        verticalCenter: viewFinder.verticalCenter
                    }

                    width: viewFinder.width * 0.7
                    height: viewFinder.height * 0.6
                    z: 2
                    border {
                        color: "red" //Theme.highlightColor
                        width: 4
                    }
                    color: "transparent"
                }

                Item {
                    id: busyIndicator

                    property alias running: busyIndicator.visible

                    anchors.fill: parent
                    visible: false
                    z: 10

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                    }

                    BusyIndicator {
                        visible: busyIndicator.visible
                        running: visible
                        anchors.centerIn: parent
                        size: BusyIndicatorSize.Large
                    }
                }
            }

            Text {
                id: statusText
                text: qsTr("Tap on viewfinder to scan")
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.Center
                color: Theme.highlightColor
            }

            Text {
                text: qsTr("The QR code should be smaller than the red border.")
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge * 2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.Center
                color: Theme.secondaryHighlightColor
            }
        }
    }
}
