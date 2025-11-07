import QtQuick
import QtQuick.Controls
import Quickshell

Rectangle {
    id: root
    width: 40
    height: 40
    radius: 8
    color: mouseArea.containsMouse ? "#313244" : "#181825"  // Catppuccin Mocha surface0/mantle

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Image {
        anchors.centerIn: parent
        width: 28
        height: 28
        source: "data:image/svg+xml;utf8,<svg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg'><path fill='%2389b4fa' d='M7.352 1.592l-1.364.813L5.2 7.2l2.58 1.456 1.364-.813L9.932 3.048zm6.175 0l-1.364.813 2.58 4.795 1.363-.813-2.58-4.795zm-3.087 1.627l-1.364.813L11.656 9.227l1.364-.813-2.58-4.795zm6.175 0l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm-6.175 3.256l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm6.175 0l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zM7.352 9.475l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm6.175 0l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm-3.087 1.627l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm6.175 0l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zM7.352 14.358l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm6.175 0l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795zm-3.087 1.627l-1.364.813 2.58 4.795 1.364-.813-2.58-4.795z'/></svg>"
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: powerMenu.open()
    }

    Menu {
        id: powerMenu

        MenuItem {
            text: "Lock"
            onTriggered: {
                Process.run(["hyprlock"])
            }
        }

        MenuItem {
            text: "Restart"
            onTriggered: {
                Process.run(["systemctl", "reboot"])
            }
        }

        MenuItem {
            text: "Shutdown"
            onTriggered: {
                Process.run(["systemctl", "poweroff"])
            }
        }
    }
}
