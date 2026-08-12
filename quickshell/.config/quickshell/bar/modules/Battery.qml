import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property int batteryPercent: 0

    implicitWidth: 24
    implicitHeight: 120

    // Outer battery module surface
    color: "#0a0a0a"

    border.width: 1
    border.color: "#242424"

    Column {
        anchors.fill: parent
        anchors.margins: 3

        spacing: 6

        Rectangle {
            id: batteryBody

            anchors.horizontalCenter: parent.horizontalCenter

            width: parent.width / 2
            height: 90

            // Deep recessed battery slot
            color: "#050505"

            border.width: 1
            border.color: "#303030"

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                height: parent.height * root.batteryPercent / 100

                // Battery charge
                color: "#d0d0d0"

                Behavior on height {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.batteryPercent + "%"

            color: "#c8c8c8"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 8

            renderType: Text.NativeRendering
        }
    }

    Process {
        id: batteryPoll

        command: [
            "cat",
            "/sys/class/power_supply/BAT0/capacity"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim())

                if (!isNaN(value))
                    root.batteryPercent = value
            }
        }
    }

    Component.onCompleted: {
        batteryPoll.running = true
    }

    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            if (!batteryPoll.running)
                batteryPoll.running = true
        }
    }
}
