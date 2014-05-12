/*
The MIT License (MIT)

Copyright (c) 2014 Steffen Förster

The tag cloud code is written by Justin Armstrong <qtdev@badpint.org> in 2011.

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
    id: root

    signal tagsSelected(variant tags)

    property color baseColor: Theme.secondaryHighlightColor
    property color textColor: Theme.primaryColor
    property color highlightedTextColor: Theme.primaryColor
    property color highlightColor: Theme.highlightColor

    function initialize() {
    }

    function loadTags() {
        console.log("loading tags ...");
        var tags = window.getServiceManager().getTags();
        console.log("loadTags, tags: ", tags.length);

        tagModel.clear();
        for (var i = 0; i < tags.length; i++) {
            tagModel.append(tags[i]);
        }
    }

    height: mainView.height; width: mainView.width

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingMedium
        width: parent.width
        contentWidth: parent.width
        contentHeight: flow.childrenRect.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Search by selected tags")
                onClicked: {
                    var tags = ""
                    for (var i = 0; i < tagModel.count; i++) {
                        if (tagModel.get(i).selected) {
                            tags += " " + tagModel.get(i).name
                        }
                    }
                    if (tags.length > 0) {
                        root.tagsSelected(tags.trim());
                    }
                }
            }
        }

        Flow {
            id: flow
            x: Theme.paddingMedium
            y: Theme.paddingMedium

            width: parent.width - 2 * Theme.paddingMedium
            spacing: 10

            property int maxHeight:0
            Repeater {
                id: repeater
                model: ListModel {
                    id: tagModel
                }
                property int minScore   //initially undefined
                property int maxScore:0
                Rectangle {
                    Text {
                        id: textBlock
                        text: model.name
                        color: model.selected ? highlightedTextColor : textColor;
                        font.bold: model.selected
                        anchors.centerIn: parent

                        //QML won't allow "onScoreChanged" due to QTBUG-17965, so
                        // we create a local ref to score and put a changed handler on that
                        property int itemScore: model.score
                        onItemScoreChanged: {
                            repeater.minScore = (repeater.minScore == undefined) ? itemScore: Math.min(itemScore, repeater.minScore)
                            repeater.maxScore = Math.max(itemScore, repeater.maxScore)
                            //console.log(index + " minScore:" + repeater.minScore + " maxScore:" + repeater.maxScore)
                        }

                        //property double scale: (Math.log(score) - Math.log(flow.minScore))/(Math.log(flow.maxScore) - Math.log(flow.minScore))
                        property double scale:  ((itemScore - repeater.minScore)/(repeater.maxScore - repeater.minScore))
                        font.pixelSize:  Math.round(scale*16) + Theme.fontSizeSmall  //you may need to tweak these values for different screen sizes

                        onHeightChanged: {
                            flow.maxHeight = Math.max(height, flow.maxHeight)
                        }
                    }
                    radius: 6
                    width: textBlock.width + 8
                    height: flow.maxHeight + 2  //all rows are the same height
                    color: model.selected ? highlightColor : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked:  {
                            tagModel.setProperty(index, "selected", !selected)
                            focus = true;
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }
    }
}
