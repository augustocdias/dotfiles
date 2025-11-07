import QtQuick
import Quickshell

Column {
    id: root
    spacing: 0

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(new Date(), "MMM")
        color: "#cba6f7"  // Catppuccin Mocha mauve
        font.pixelSize: 11
        font.family: "monospace"
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDate(new Date(), "dd")
        color: "#cba6f7"  // Catppuccin Mocha mauve
        font.pixelSize: 14
        font.family: "monospace"
        font.bold: true
    }

    Timer {
        interval: 60000  // Update every minute
        running: true
        repeat: true
        onTriggered: {
            root.children[0].text = Qt.formatDate(new Date(), "MMM");
            root.children[1].text = Qt.formatDate(new Date(), "dd");
        }
    }
}
