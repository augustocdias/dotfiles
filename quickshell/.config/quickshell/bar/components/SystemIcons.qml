import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: root
    width: 40
    height: iconsColumn.implicitHeight + 10
    radius: 20
    color: "#181825"  // Catppuccin Mocha mantle

    ColumnLayout {
        id: iconsColumn
        anchors.centerIn: parent
        spacing: 8

        // Network icon (static for now)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰖩"  // Nerd font wifi icon
            color: "#89dceb"  // Catppuccin Mocha sky
            font.pixelSize: 16
            font.family: "monospace"
        }

        // Bluetooth icon (static for now)
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰂯"  // Nerd font bluetooth icon
            color: "#89dceb"  // Catppuccin Mocha sky
            font.pixelSize: 16
            font.family: "monospace"
        }

        // Volume icon
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                if (!Pipewire.defaultAudioSink) return "󰖁";
                const vol = Pipewire.defaultAudioSink.volume;
                const muted = Pipewire.defaultAudioSink.muted;

                if (muted) return "󰖁";  // Muted
                if (vol > 0.66) return "󰕾";  // High
                if (vol > 0.33) return "󰖀";  // Medium
                return "󰕿";  // Low
            }
            color: Pipewire.defaultAudioSink?.muted ? "#f38ba8" : "#a6e3a1"  // Red if muted, green otherwise
            font.pixelSize: 16
            font.family: "monospace"
        }

        // Volume percentage
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.volume * 100) + "%" : "N/A"
            color: "#cdd6f4"  // Catppuccin Mocha text
            font.pixelSize: 9
            font.family: "monospace"
        }
    }
}
