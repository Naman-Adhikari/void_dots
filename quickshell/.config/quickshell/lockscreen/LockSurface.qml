import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects
import Quickshell.Wayland

Rectangle {
    id: root

    required property LockContext context

    color: "#000000"

    // ============================================================
    // BACKGROUND
    // ============================================================

    Image {
        anchors.fill: parent

        source: "lock.png"

        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
    }

    // Slight darkening over the entire image.
    // Keeps the artwork visible but makes the UI readable.
    Rectangle {
        anchors.fill: parent

        color: "#000000"
        opacity: 0.18
    }

    // ============================================================
    // RIGHT SIDE GRADIENT
    //
    // Darkens the empty area on the right without covering the
    // character with a giant opaque panel.
    // ============================================================

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        width: parent.width * 0.58

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#00000000"
            }

            GradientStop {
                position: 0.35
                color: "#00000088"
            }

            GradientStop {
                position: 0.75
                color: "#000000dd"
            }

            GradientStop {
                position: 1.0
                color: "#000000f5"
            }
        }
    }

    // ============================================================
    // SUBTLE TEXTURE / SCANLINES
    // ============================================================

    Column {
        anchors.fill: parent

        spacing: 7

        opacity: 0.025

        Repeater {
            model: 300

            Rectangle {
                width: parent.width
                height: 1

                color: "#ffffff"
            }
        }
    }

    // ============================================================
    // LEFT TOP SYSTEM LABEL
    // ============================================================

    Column {
        anchors {
            left: parent.left
            top: parent.top

            leftMargin: 34
            topMargin: 28
        }

        spacing: 4

        Text {
            text: "SYSTEM // LOCKED"

            color: "#c8c8c8"

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 12
                bold: true
                letterSpacing: 2
            }
        }

        Rectangle {
            width: 110
            height: 1

            color: "#777777"
        }

        Text {
            text: "AUTHORIZATION REQUIRED"

            color: "#555555"

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 9
                letterSpacing: 1.5
            }
        }
    }

    // ============================================================
    // RIGHT AUTHENTICATION AREA
    // ============================================================

    Item {
        id: authArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        width: Math.min(parent.width * 0.42, 620)

        // --------------------------------------------------------
        // Main authentication column
        // --------------------------------------------------------

        Column {
            id: authColumn

            width: Math.min(parent.width - 100, 430)

            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            spacing: 18

            // ----------------------------------------------------
            // CLOCK
            // ----------------------------------------------------

            Text {
                id: clock

                property var date: new Date()

                width: parent.width

                horizontalAlignment: Text.AlignLeft

                renderType: Text.NativeRendering

                color: "#f0f0f0"

                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 72
                    bold: true
                    letterSpacing: 2
                }

                Timer {
                    running: true
                    repeat: true
                    interval: 1000

                    onTriggered: clock.date = new Date()
                }

                text: {
                    const hours =
                        date.getHours()
                            .toString()
                            .padStart(2, "0")

                    const minutes =
                        date.getMinutes()
                            .toString()
                            .padStart(2, "0")

                    return hours + ":" + minutes
                }
            }

            // ----------------------------------------------------
            // DATE
            // ----------------------------------------------------

            Text {
                width: parent.width

                text:
                    Qt.formatDateTime(
                        clock.date,
                        "dddd, MMMM d"
                    ).toUpperCase()

                color: "#777777"

                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 11
                    letterSpacing: 3
                }
            }

            // Decorative divider

            Rectangle {
                width: parent.width
                height: 1

                color: "#333333"

                Rectangle {
                    width: 80
                    height: 1

                    color: "#d0d0d0"
                }
            }

            Item {
                width: 1
                height: 10
            }

            // ----------------------------------------------------
            // AUTH LABEL
            // ----------------------------------------------------

            Text {
                text: "IDENTITY VERIFICATION"

                color: "#cfcfcf"

                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 13
                    bold: true
                    letterSpacing: 3
                }
            }

            Text {
                text: "ENTER SYSTEM CREDENTIAL"

                color: "#555555"

                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 9
                    letterSpacing: 2
                }
            }

            Item {
                width: 1
                height: 4
            }

            // ====================================================
            // PASSWORD FIELD
            // ====================================================

            TextField {
                id: passwordBox

                width: parent.width
                height: 58

                focus: true

                enabled: !root.context.unlockInProgress

                echoMode: TextInput.Password

                inputMethodHints:
                    Qt.ImhSensitiveData

                padding: 16

                color: "#eeeeee"

                placeholderText: "PASSWORD"

                placeholderTextColor: "#555555"

                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 13
                    letterSpacing: 2
                }

                background: Rectangle {
                    color: "#080808"

                    border.width: 1

                    border.color:
                        passwordBox.activeFocus
                        ? "#bdbdbd"
                        : "#303030"

                    // Left accent
                    Rectangle {
                        width: 3
                        height: parent.height

                        color:
                            passwordBox.activeFocus
                            ? "#e0e0e0"
                            : "#555555"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }

                    // Bottom line
                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }

                        height: 1

                        color:
                            passwordBox.activeFocus
                            ? "#d0d0d0"
                            : "#222222"
                    }
                }

                onTextChanged:
                    root.context.currentText = text

                onAccepted:
                    root.context.tryUnlock()

                Connections {
                    target: root.context

                    function onCurrentTextChanged() {
                        if (
                            passwordBox.text
                            !== root.context.currentText
                        ) {
                            passwordBox.text =
                                root.context.currentText
                        }
                    }
                }
            }

            // ====================================================
            // UNLOCK BUTTON
            // ====================================================

            Button {
                id: unlockButton

                width: parent.width
                height: 52

                enabled:
                    !root.context.unlockInProgress
                    && root.context.currentText !== ""

                focusPolicy: Qt.NoFocus

                onClicked:
                    root.context.tryUnlock()

                contentItem: Text {
                    text:
                        root.context.unlockInProgress
                        ? "VERIFYING..."
                        : "UNLOCK SYSTEM"

                    color:
                        unlockButton.enabled
                        ? "#ffffff"
                        : "#555555"

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter

                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 11
                        bold: true
                        letterSpacing: 3
                    }
                }

                background: Rectangle {
                    color:
                        unlockButton.down
                        ? "#eeeeee"
                        : unlockButton.hovered
                            ? "#222222"
                            : "#111111"

                    border.width: 1

                    border.color:
                        unlockButton.enabled
                        ? "#888888"
                        : "#303030"

                    Rectangle {
                        visible: unlockButton.hovered

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }

                        height: 1

                        color: "#ffffff"
                    }
                }
            }

            // ====================================================
            // STATUS / FAILURE
            // ====================================================

            Item {
                width: parent.width
                height: 24

                Text {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    visible: root.context.showFailure

                    text: "// ACCESS DENIED"

                    color: "#cfcfcf"

                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 10
                        bold: true
                        letterSpacing: 2
                    }
                }

                Text {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    text:
                        root.context.unlockInProgress
                        ? "PROCESSING"
                        : "READY"

                    color:
                        root.context.unlockInProgress
                        ? "#dddddd"
                        : "#555555"

                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 9
                        letterSpacing: 2
                    }
                }
            }
        }
    }

    // ============================================================
    // BOTTOM LEFT
    // ============================================================

    Text {
        anchors {
            left: parent.left
            bottom: parent.bottom

            leftMargin: 34
            bottomMargin: 28
        }

        text: "NIRI / WAYLAND  //  SECURE SESSION"

        color: "#4a4a4a"

        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 9
            letterSpacing: 2
        }
    }

    // ============================================================
    // BOTTOM RIGHT DECORATION
    // ============================================================

    Row {
        anchors {
            right: parent.right
            bottom: parent.bottom

            rightMargin: 34
            bottomMargin: 28
        }

        spacing: 8

        Rectangle {
            width: 5
            height: 5
            color: "#888888"
        }

        Text {
            text: "LOCKED"

            color: "#777777"

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 9
                letterSpacing: 2
            }
        }
    }

    // ============================================================
    // ESCAPE / EMERGENCY EXIT
    // ============================================================

    Button {
        anchors {
            right: parent.right
            top: parent.top

            rightMargin: 34
            topMargin: 28
        }

        width: 110
        height: 28

        opacity: 0.35

        text: "EXIT"

        onClicked:
            context.unlocked()

        contentItem: Text {
            text: parent.text

            color: "#aaaaaa"

            horizontalAlignment:
                Text.AlignHCenter

            verticalAlignment:
                Text.AlignVCenter

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 9
                letterSpacing: 2
            }
        }

        background: Rectangle {
            color: "#080808"

            border.width: 1
            border.color: "#555555"
        }
    }

    // Always refocus password field when clicked anywhere
    MouseArea {
        anchors.fill: parent

        z: -1

        onClicked:
            passwordBox.forceActiveFocus()
    }

    Component.onCompleted: {
        passwordBox.forceActiveFocus()
    }
}
