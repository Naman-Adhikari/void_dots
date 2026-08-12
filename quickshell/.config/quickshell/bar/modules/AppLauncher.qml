import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool open: false

    visible: open
    focusable: true
    color: "transparent"

    implicitWidth: 850
    implicitHeight: 600

    // ============================================================
    // Monochrome palette
    // ============================================================

    readonly property color accent: "#707070"
    readonly property color accentBright: "#d0d0d0"

    readonly property color textColor: "#e0e0e0"
    readonly property color textMuted: "#909090"

    readonly property color panelBg: "#080808"
    readonly property color panelInner: "#0d0d0d"

    readonly property color inputBg: "#050505"

    readonly property color itemBg: "#101010"
    readonly property color itemHover: "#1a1a1a"

    readonly property color placeholderColor: "#666666"

    // ============================================================
    // Launcher control
    // ============================================================

    function resetSearch() {
        search.text = ""
        panel.results = AppService.search("")
        list.currentIndex = 0

        Qt.callLater(function() {
            search.forceActiveFocus()
        })
    }

    function toggleLauncher() {
        open = !open

        if (open)
            resetSearch()
    }

    function openLauncher() {
        open = true
        resetSearch()
    }

    function closeLauncher() {
        open = false
    }

    function launchCurrent() {
        if (list.currentIndex < 0 ||
            list.currentIndex >= panel.results.length)
            return

        const app = panel.results[list.currentIndex]

        launcher.command = [
            "sh",
            "-c",
            app.exec
        ]

        launcher.running = true
        root.open = false
    }

    // ============================================================
    // IPC
    // ============================================================

    IpcHandler {
        target: "launcher"

        function toggleLauncher() {
            root.toggleLauncher()
        }

        function openLauncher() {
            root.openLauncher()
        }

        function closeLauncher() {
            root.closeLauncher()
        }
    }

    Process {
        id: launcher
    }

    // ============================================================
    // Absolute black background
    // ============================================================

    Rectangle {
        anchors.fill: parent

        color: "#000000"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.open = false
            }
        }
    }

    // ============================================================
    // Main launcher panel
    // ============================================================

    Rectangle {
        id: panel

        anchors.centerIn: parent

        width: 800
        height: 550

        radius: 10

        color: root.panelBg

        border.width: 1
        border.color: "#3a3a3a"

        property var results: []

        // ========================================================
        // Inner surface
        // ========================================================

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            radius: 8

            color: root.panelInner

            border.width: 1
            border.color: "#161616"
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24

            spacing: 16

            // ====================================================
            // Title
            // ====================================================

            Text {
                text: "◢ SYSTEM APPLICATION LAUNCHER ◣"

                color: root.accentBright

                font.pixelSize: 18
                font.bold: true
                font.family: "JetBrains Mono"
            }

            // ====================================================
            // Search input
            // ====================================================

            Rectangle {
                width: parent.width
                height: 54

                radius: 6

                color: root.inputBg

                border.width: 1
                border.color: "#454545"

                Row {
                    anchors.fill: parent
                    anchors.margins: 10

                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: ">"

                        color: "#f0f0f0"

                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrains Mono"
                    }

                    TextField {
                        id: search

                        width: parent.width - 40

                        focus: true

                        color: root.textColor

                        placeholderText: "Search applications..."
                        placeholderTextColor: root.placeholderColor

                        font.family: "JetBrains Mono"

                        background: Rectangle {
                            color: "transparent"
                        }

                        // ==========================================
                        // Update results
                        // ==========================================

                        onTextChanged: {
                            panel.results = AppService.search(text)
                            list.currentIndex = 0
                        }

                        // ==========================================
                        // Launch selected application
                        // ==========================================

                        onAccepted: {
                            root.launchCurrent()
                        }

                        // ==========================================
                        // Keyboard navigation
                        // ==========================================

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Down) {

                                if (panel.results.length > 0) {
                                    list.currentIndex = Math.min(
                                        list.currentIndex + 1,
                                        panel.results.length - 1
                                    )

                                    list.positionViewAtIndex(
                                        list.currentIndex,
                                        ListView.Contain
                                    )
                                }

                                event.accepted = true
                            }

                            else if (event.key === Qt.Key_Up) {

                                if (panel.results.length > 0) {
                                    list.currentIndex = Math.max(
                                        list.currentIndex - 1,
                                        0
                                    )

                                    list.positionViewAtIndex(
                                        list.currentIndex,
                                        ListView.Contain
                                    )
                                }

                                event.accepted = true
                            }

                            else if (event.key === Qt.Key_Escape) {
                                root.open = false
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            // ====================================================
            // Divider
            // ====================================================

            Rectangle {
                width: parent.width
                height: 1

                color: "#3a3a3a"
                opacity: 0.7
            }

            // ====================================================
            // Application results
            // ====================================================

            ListView {
                id: list

                width: parent.width
                height: parent.height - 120

                clip: true
                spacing: 4

                model: panel.results

                currentIndex: 0
                focus: false

                // ================================================
                // Keyboard selection highlight
                // ================================================

                highlight: Rectangle {
                    radius: 4

                    color: root.itemHover

                    border.width: 1
                    border.color: "#707070"
                }

                highlightFollowsCurrentItem: true

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 42

                    radius: 4

                    color: ListView.isCurrentItem
                        ? root.itemHover
                        : (mouse.containsMouse
                            ? root.itemHover
                            : root.itemBg)

                    border.width: 1

                    border.color: ListView.isCurrentItem
                        ? "#707070"
                        : (mouse.containsMouse
                            ? "#484848"
                            : "#181818")

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.left: parent.left
                        anchors.leftMargin: 14

                        text: modelData.name

                        color: ListView.isCurrentItem
                            ? "#ffffff"
                            : (mouse.containsMouse
                                ? "#ffffff"
                                : root.textColor)

                        font.pixelSize: 14
                        font.family: "JetBrains Mono"
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            list.currentIndex = index

                            launcher.command = [
                                "sh",
                                "-c",
                                modelData.exec
                            ]

                            launcher.running = true
                            root.open = false
                        }
                    }
                }
            }
        }
    }

    // ============================================================
    // External launcher toggle
    // ============================================================

    Connections {
        target: AppService

        function onToggleRequested() {
            root.open = !root.open

            if (root.open) {
                root.resetSearch()

                root.raise()
                root.requestActivate()
            }
        }
    }
}
