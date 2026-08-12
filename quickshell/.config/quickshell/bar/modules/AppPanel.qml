import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    width: 38
    height: 38
    radius: 8

    color: mouse.containsMouse
        ? "#161616"
        : "transparent"

    border.width: mouse.containsMouse ? 1 : 0
    border.color: "#3a3a3a"

    Text {
        anchors.centerIn: parent

        text: "󰀻"

        color: mouse.containsMouse
            ? "#ffffff"
            : "#cfcfcf"

        font.pixelSize: 20
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            AppService.toggle()
        }
    }
}
