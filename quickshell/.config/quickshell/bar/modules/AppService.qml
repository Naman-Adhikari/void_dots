pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var apps: []

    signal cacheReady()
    signal toggleRequested()

    function toggle() {
		console.log("toggle called")
        toggleRequested()
    }

    property Process scanner: Process {
        command: [
            "/home/lostfromlight/.config/quickshell/bar/modules/desktop-cache.sh"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.apps = JSON.parse(text)
                root.cacheReady()
            }
        }

        running: true
    }

    function search(query) {
        if (query.length === 0)
            return apps.slice(0, 20)

        query = query.toLowerCase()

        return apps.filter(app =>
            app.name.toLowerCase().includes(query)
        ).slice(0, 20)
    }
}
