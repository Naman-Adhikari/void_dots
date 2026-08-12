import QtQuick
import QtQuick.Layouts

Rectangle {
    implicitWidth: 35
    implicitHeight: 90

    // Raised module surface
    color: "#0a0a0a"

    border.width: 1
    border.color: "#242424"

    QtObject {
        id: time
        property date date: new Date()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: {
            time.date = new Date()
        }
    }

    Column {
        anchors.centerIn: parent

        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatTime(time.date, "HH")

            color: "#e0e0e0"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatTime(time.date, "mm")

            color: "#ffffff"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true

            renderType: Text.NativeRendering
        }

        Rectangle {
            width: 18
            height: 1

            color: "#505050"

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "ddd").toUpperCase()

            color: "#a0a0a0"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "dd")

            color: "#d0d0d0"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: Qt.formatDate(time.date, "MMM").toUpperCase()

            color: "#808080"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 9

            renderType: Text.NativeRendering
        }
    }
}
