import QtQuick

Rectangle {
    id: root

    signal toggleRequested()

    width: 24
    height: 24

    // Subtle button surface
    color: mouse.containsMouse
        ? "#181818"
        : "#0a0a0a"

    border.width: 1
    border.color: mouse.containsMouse
        ? "#484848"
        : "#202020"

    Text {
        anchors.centerIn: parent

        text: "󰅌"

        color: mouse.containsMouse
            ? "#ffffff"
            : "#bdbdbd"

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: root.toggleRequested()
    }
}
