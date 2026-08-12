import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool open: false

    // ============================================================
    // Monochrome palette
    // ============================================================

    readonly property color accent: "#707070"
    readonly property color accentBright: "#e0e0e0"

    readonly property color textColor: "#d0d0d0"

    readonly property color panelBg: "#080808"

    readonly property color itemBg: "#0d0d0d"
    readonly property color itemHover: "#1a1a1a"

    visible: open
    focusable: true

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 400
    exclusiveZone: 0

    color: "transparent"

    ListModel {
        id: clipboardModel
    }

    function loadHistory() {
        clipboardModel.clear()
        historyProcess.running = true
    }

    function toggleClipboard() {
        open = !open

        if (open) {
            loadHistory()
            historyView.forceActiveFocus()
        }
    }

    function openClipboard() {
        open = true
        loadHistory()
        historyView.forceActiveFocus()
    }

    function closeClipboard() {
        open = false
    }

    IpcHandler {
        target: "clipboard"

        function toggleClipboard() {
            root.toggleClipboard()
        }

        function openClipboard() {
            root.openClipboard()
        }

        function closeClipboard() {
            root.closeClipboard()
        }
    }

    // ============================================================
    // Main panel
    // ============================================================

    Rectangle {
        anchors.fill: parent

        color: root.panelBg

        border.width: 1
        border.color: "#303030"

        // Slight inner border for depth
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2

            color: "#0a0a0a"

            border.width: 1
            border.color: "#141414"
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12

            spacing: 8

            Text {
                text: "CLIPBOARD"

                color: root.accentBright

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1

                color: "#505050"
                opacity: 0.7
            }

            ListView {
                id: historyView

                width: parent.width
                height: parent.height

                clip: true

                model: clipboardModel

                spacing: 4

                focus: root.open
                currentIndex: 0

                keyNavigationWraps: true

                highlight: Rectangle {
                    radius: 4

                    color: root.itemHover

                    border.width: 1
                    border.color: "#707070"
                }

                highlightFollowsCurrentItem: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        currentIndex = Math.min(
                            currentIndex + 1,
                            clipboardModel.count - 1
                        )
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_K) {
                        currentIndex = Math.max(
                            currentIndex - 1,
                            0
                        )
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return ||
                        event.key === Qt.Key_Enter) {

                        if (currentIndex >= 0) {
                            const item = clipboardModel.get(currentIndex)

                            copyProcess.entryId = item.itemId
                            copyProcess.running = true

                            root.open = false
                        }

                        event.accepted = true
                    }

                    if (event.key === Qt.Key_Escape) {
                        root.open = false
                        event.accepted = true
                    }
                }

                delegate: Rectangle {
                    required property string itemId
                    required property string preview

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
                            : "#202020")

                    Text {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        verticalAlignment: Text.AlignVCenter

                        text: preview

                        elide: Text.ElideRight

                        color: ListView.isCurrentItem
                            ? "#ffffff"
                            : root.textColor

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            historyView.currentIndex = index

                            copyProcess.entryId = itemId
                            copyProcess.running = true

                            root.open = false
                        }
                    }
                }
            }
        }
    }

    Process {
        id: historyProcess

        command: [
            "sh",
            "-c",
            "cliphist list"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")

                for (const line of lines) {
                    if (!line.trim())
                        continue

                    const firstSpace = line.indexOf(" ")

                    if (firstSpace < 0)
                        continue

                    clipboardModel.append({
                        itemId: line.substring(0, firstSpace),
                        preview: line.substring(firstSpace + 1)
                    })
                }
            }
        }
    }

    Process {
        id: copyProcess

        property string entryId: ""

        command: [
            "sh",
            "-c",
            `cliphist decode "${entryId}" | wl-copy`
        ]
    }

    onOpenChanged: {
        if (open) {
            loadHistory()
            historyView.forceActiveFocus()
        }
    }
}
