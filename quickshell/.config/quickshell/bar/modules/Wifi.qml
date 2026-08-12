import QtQuick

Rectangle {
    id: root

    implicitWidth: 30
    implicitHeight: 48

    color: "transparent"

    signal togglePanel()

    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.togglePanel()
        }
    }

    Text {
        anchors.centerIn: parent

        text:
            !WifiService.enabled ? "󰖪" :
            WifiService.strength > 75 ? "󰤨" :
            WifiService.strength > 50 ? "󰤥" :
            WifiService.strength > 25 ? "󰤢" :
            "󰤟"

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20
        color: "#8c8d91"
    }
}
