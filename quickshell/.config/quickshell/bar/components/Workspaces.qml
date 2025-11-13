import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

ColumnLayout {
    id: root
    required property var screen
    spacing: 5

    Repeater {
        model: 10

        Rectangle {
            required property int index
            property int workspaceId: index + 1
            property bool isActive: Hyprland.activeWorkspace?.id === workspaceId
            property bool isOccupied: {
                for (const ws of Hyprland.workspaces.values) {
                    if (ws.id === workspaceId && ws.windows && ws.windows.length > 0) {
                        return true;
                    }
                }
                return false;
            }

            Layout.alignment: Qt.AlignHCenter
            width: 30
            height: 30
            radius: 15

            color: isActive ? "#89b4fa" : (isOccupied ? "#313244" : "transparent")
            border.color: isOccupied && !isActive ? "#45475a" : "transparent"
            border.width: 2

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent
                text: parent.workspaceId
                color: parent.isActive ? "#1e1e2e" : "#cdd6f4"
                font.pixelSize: 12
                font.bold: parent.isActive
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch("workspace " + parent.workspaceId);
                }
            }
        }
    }
}
