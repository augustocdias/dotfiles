import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

ColumnLayout {
    id: root
    spacing: 5

    Repeater {
        model: SystemTray.items

        Item {
            required property SystemTrayItem modelData

            Layout.alignment: Qt.AlignHCenter
            width: 30
            height: 30

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: modelData.icon?.toString() ?? ""
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        modelData.menu?.open();
                    }
                }
            }
        }
    }
}
