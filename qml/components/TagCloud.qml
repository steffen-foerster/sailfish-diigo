/**
 * The tag cloud code is written by Justin Armstrong <qtdev@badpint.org> in 2011.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: tagCloud

    signal tagsSelected(variant tags)

    property variant model
    property color baseColor: Theme.secondaryHighlightColor
    property color textColor: Theme.primaryColor
    property color highlightedTextColor: Theme.primaryColor
    property color highlightColor: Theme.highlightColor

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        boundsBehavior: Flickable.DragOverBounds
        interactive: true
        contentWidth: parent.width
        contentHeight: flow.childrenRect.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Search")
                onClicked: {
                    var tags = ""
                    for (var i = 0; i < tagCloud.model.count; i++) {
                        if (tagCloud.model.get(i).selected) {
                            tags += " " + tagCloud.model.get(i).name
                        }
                    }
                    if (tags.length > 0) {
                        tagsSelected(tags.trim());
                    }
                }
            }
        }

        Flow {
            id: flow
            x: Theme.paddingMedium
            width: parent.width - 2 * Theme.paddingMedium
            spacing: 10

            property int maxHeight:0
            Repeater {
                id: repeater
                model: tagCloud.model
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
                            tagCloud.model.setProperty(index, "selected", !selected)
                            focus = true;
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }
    }

    //optional - scroll indicator
    /*
    Rectangle {
        id: scrollIndicator
        anchors.right: flickable.right
        width:4
        height:flickable.visibleArea.heightRatio * flickable.height
        y:flickable.visibleArea.yPosition * flickable.height
        color:textColor
        opacity:0
        states: State {
            name: "ShowBars"
            when: flickable.movingVertically
            PropertyChanges { target:scrollIndicator; opacity: 1 }
        }
        transitions: Transition {
            NumberAnimation { properties: "opacity"; duration: 400 }
        }

    }
    */
}
