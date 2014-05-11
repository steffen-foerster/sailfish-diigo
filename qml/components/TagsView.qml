import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    signal tagsSelected(variant tags)

    function initialize() {
        tagCloud.tagsSelected.connect(root.tagsSelected)
    }

    function loadTags() {
        console.log("loading tags ...");
        var tags = getServiceManager().getTags();
        console.log("loadTags, tags: ", tags.length);

        tagModel.clear();
        for (var i = 0; i < tags.length; i++) {
            tagModel.append(tags[i]);
        }
    }

    height: mainView.height; width: mainView.width

    TagCloud {
        id: tagCloud
        width: parent.width
        height: parent.height

        model: ListModel {
            id: tagModel
        }
    }

    /*
    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        width: parent.width

        Repeater {
            model: ListModel {
                id: tagModel
            }

            Flow {
                anchors.fill: flickable
                spacing: 10

                Text {
                    text: model.tag + "(" + model.count + ")";
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.primaryColor
                }

            }
        }
    }
    */
}
