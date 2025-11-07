import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Upower
import Quickshell.Services.SystemTray as ST

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

        // Battery indicator
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                if (!Upower.displayDevice) return "󰂑";  // Battery icon
                const percent = Upower.displayDevice.percentage * 100;
                const charging = Upower.displayDevice.state === UPowerDeviceState.Charging;

                if (charging) return "󰂄";  // Charging
                if (percent > 90) return "󰁹";
                if (percent > 80) return "󰂂";
                if (percent > 70) return "󰂁";
                if (percent > 60) return "󰂀";
                if (percent > 50) return "󰁿";
                if (percent > 40) return "󰁾";
                if (percent > 30) return "󰁽";
                if (percent > 20) return "󰁼";
                if (percent > 10) return "󰁻";
                return "󰁺";  // Low battery
            }
            color: {
                if (!Upower.displayDevice) return "#a6e3a1";  // Catppuccin Mocha green
                const percent = Upower.displayDevice.percentage * 100;
                return percent < 20 ? "#f38ba8" : "#a6e3a1";  // Red if low, green otherwise
            }
            font.pixelSize: 16
            font.family: "monospace"
        }

        // Battery percentage
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Upower.displayDevice ? Math.round(Upower.displayDevice.percentage * 100) + "%" : "N/A"
            color: "#cdd6f4"  // Catppuccin Mocha text
            font.pixelSize: 9
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
