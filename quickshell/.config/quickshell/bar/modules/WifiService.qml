pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled: false
    property bool connected: false
    property string ssid: ""
    property int strength: 0

    function refresh() {
        state.running = true
    }

    Process {
        id: state

        command: [
            "sh",
            "-c",
            `nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi |
            grep '^yes' |
            head -n1`
        ]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(":");

                if (parts.length >= 3) {
                    root.connected = true;
                    root.ssid = parts[1];
                    root.strength = parseInt(parts[2]);
                } else {
                    root.connected = false;
                    root.ssid = "";
                    root.strength = 0;
                }
            }
        }
    }

    Process {
        id: radio

        command: [
            "nmcli",
            "-t",
            "-f",
            "WIFI",
            "general"
        ]

        stdout: SplitParser {
            onRead: data => {
                root.enabled = data.trim() === "enabled";
            }
        }
    }

    Process {
        id: monitor

        command: [
            "nmcli",
            "monitor"
        ]

        running: true

        stdout: SplitParser {
            onRead: _ => root.refresh()
        }
    }

    Component.onCompleted: {
        refresh()
        radio.running = true
    }
}
