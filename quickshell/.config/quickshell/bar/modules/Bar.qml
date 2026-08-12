import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 52
    exclusiveZone: implicitWidth + 8

    color: "transparent"

    ClipboardPanel {
        id: clipboardPanel
    }

    WifiPanel {
        id: wifiPanel
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4

        radius: 1

        // Main bar surface
        color: "#000000"

        border.width: 1
        border.color: "#242424"

        ColumnLayout {
            anchors.fill: parent

            anchors.topMargin: 4
            anchors.bottomMargin: 5

            spacing: 12

            Workspaces {
                Layout.alignment: Qt.AlignHCenter
            }

            AppPanel {
                Layout.alignment: Qt.AlignHCenter
            }

            Item {
                Layout.fillHeight: true
            }

            ClipboardButton {
                Layout.alignment: Qt.AlignHCenter

                onToggleRequested: {
                    clipboardPanel.open = !clipboardPanel.open
                }
            }

            Wifi {
                Layout.alignment: Qt.AlignHCenter

                onTogglePanel: {
                    wifiPanel.visible = !wifiPanel.visible
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter

                width: 26
                height: 1

                // Subtle metallic divider
                color: "#3a3a3a"
                opacity: 0.9
            }

            Battery {
                Layout.alignment: Qt.AlignHCenter
            }

            Item {
                Layout.preferredHeight: 8
            }

            Clock {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
