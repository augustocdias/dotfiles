import QtQuick
import Quickshell

Column {
    id: root
    spacing: 2

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(new Date(), "HH")
        color: "#f5c2e7"  // Catppuccin Mocha pink
        font.pixelSize: 14
        font.family: "monospace"
        font.bold: true
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatTime(new Date(), "mm")
        color: "#f5c2e7"  // Catppuccin Mocha pink
        font.pixelSize: 14
        font.family: "monospace"
        font.bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Force text update
            root.children[0].text = Qt.formatTime(new Date(), "HH");
            root.children[1].text = Qt.formatTime(new Date(), "mm");
        }
    }
}
