import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "components"

Rectangle {
    id: root
    required property var screen

    color: "#1e1e2e"  // Catppuccin Mocha base

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 10

        // Top section: Nix logo + workspaces
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 10

            NixLogo {
                Layout.alignment: Qt.AlignHCenter
            }

            Workspaces {
                Layout.alignment: Qt.AlignHCenter
                screen: root.screen
            }
        }

        // Middle section: Active window
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ActiveWindow {
                anchors.centerIn: parent
                width: parent.width
            }
        }

        // Bottom section: System indicators
        ColumnLayout {
            Layout.alignment: Qt.AlignBottom
            spacing: 8

            SystemTray {
                Layout.alignment: Qt.AlignHCenter
            }

            SystemIcons {
                Layout.alignment: Qt.AlignHCenter
            }

            DateDisplay {
                Layout.alignment: Qt.AlignHCenter
            }

            ClockDisplay {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
