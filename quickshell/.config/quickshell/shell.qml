import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "bar"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            property var screen: modelData

            anchors {
                left: true
                top: true
                bottom: true
            }

            implicitWidth: 50
            implicitHeight: screen.height

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: width

            color: "transparent"

            Bar {
                anchors.fill: parent
                screen: screen
            }
        }
    }
}
