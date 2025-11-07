import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    implicitHeight: windowText.implicitHeight
    implicitWidth: windowText.implicitWidth

    Text {
        id: windowText
        anchors.centerIn: parent
        width: parent.width - 10

        text: {
            const window = Hyprland.focusedWindow;
            if (window && window.title) {
                return window.title;
            }
            return "Desktop";
        }

        color: "#cdd6f4"  // Catppuccin Mocha text
        font.pixelSize: 11
        font.family: "monospace"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        elide: Text.ElideMiddle
        maximumLineCount: 3

        transform: Rotation {
            angle: 90
            origin.x: windowText.width / 2
            origin.y: windowText.height / 2
        }
    }
}
