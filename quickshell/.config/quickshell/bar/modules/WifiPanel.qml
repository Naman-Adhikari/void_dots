import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "./"

PanelWindow {
    id: panel

    visible: false

    // ============================================================
    // Monochrome palette
    // ============================================================

    readonly property color accent: "#707070"
    readonly property color accentBright: "#e0e0e0"

    readonly property color textColor: "#d0d0d0"
    readonly property color mutedText: "#707070"

    readonly property color panelBg: "#080808"
    readonly property color panelInner: "#0d0d0d"

    readonly property color cardBg: "#101010"

    readonly property color itemBg: "#0d0d0d"
    readonly property color itemHover: "#1a1a1a"

    anchors {
        right: true
        bottom: true
    }

    implicitWidth: 380
    implicitHeight: 560

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: panel.panelBg

        border.width: 1
        border.color: "#3a3a3a"

        // Inner recessed layer
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            color: panel.panelInner

            border.width: 1
            border.color: "#181818"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 14

            Label {
                text: "󰖩 Wi-Fi"

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                font.bold: true

                color: "#f0f0f0"
            }

            // ====================================================
            // Connection status card
            // ====================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90

                color: panel.cardBg

                border.width: 1
                border.color: "#303030"

                Column {
                    anchors.fill: parent
                    anchors.margins: 12

                    spacing: 6

                    Label {
                        text: WifiService.connected
                            ? "CONNECTED"
                            : "DISCONNECTED"

                        color: WifiService.connected
                            ? "#ffffff"
                            : "#909090"

                        font.bold: true
                    }

                    Label {
                        text: WifiService.connected
                            ? WifiService.ssid
                            : "No active network"

                        color: panel.textColor
                    }

                    Label {
                        text: WifiService.connected
                            ? "Signal: " + WifiService.strength + "%"
                            : ""

                        color: panel.mutedText
                    }
                }
            }

            // ====================================================
            // Wireless toggle
            // ====================================================

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Wireless Radio"

                    color: panel.textColor
                    Layout.fillWidth: true
                }

                Switch {
                    checked: WifiService.enabled

                    onClicked: {
                        toggle.running = true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: "#484848"
                opacity: 0.7
            }

            Label {
                text: "AVAILABLE NETWORKS"

                color: "#bdbdbd"
                font.bold: true
            }

            // ====================================================
            // Network list
            // ====================================================

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                ListView {
                    id: wifiList

                    model: wifiModel

                    spacing: 6

                    delegate: Rectangle {
                        required property string ssid
                        required property string signal

                        width: wifiList.width
                        height: 64

                        color: mouse.containsMouse
                            ? panel.itemHover
                            : panel.itemBg

                        border.width: 1
                        border.color: mouse.containsMouse
                            ? "#707070"
                            : "#202020"

                        MouseArea {
                            id: mouse

                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                connectProc.command = [
                                    "nmcli",
                                    "device",
                                    "wifi",
                                    "connect",
                                    ssid
                                ]

                                connectProc.running = true
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12

                            spacing: 12

                            Label {
                                text: "󰤨"

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18

                                color: mouse.containsMouse
                                    ? "#ffffff"
                                    : "#b0b0b0"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: ssid

                                    color: panel.textColor
                                    font.bold: true

                                    elide: Text.ElideRight
                                }

                                Label {
                                    text: "Signal Strength"

                                    color: panel.mutedText
                                    font.pixelSize: 11
                                }
                            }

                            Label {
                                text: signal + "%"

                                color: mouse.containsMouse
                                    ? "#ffffff"
                                    : "#b0b0b0"

                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: wifiModel
    }

    Process {
        id: scan

        command: [
            "nmcli",
            "-t",
            "-f",
            "SSID,SIGNAL",
            "device",
            "wifi",
            "list"
        ]

        stdout: SplitParser {
            onRead: data => {
                wifiModel.clear()

                for (let line of data.trim().split("\n")) {
                    let parts = line.split(":")

                    if (parts.length < 2)
                        continue

                    wifiModel.append({
                        ssid: parts[0],
                        signal: parts[1]
                    })
                }
            }
        }
    }

    Process {
        id: connectProc
    }

    Process {
        id: toggle

        command: [
            "nmcli",
            "radio",
            "wifi",
            WifiService.enabled ? "off" : "on"
        ]
    }

    onVisibleChanged: {
        console.log("WifiPanel visible:", visible)

        if (visible)
            scan.running = true
    }
}
