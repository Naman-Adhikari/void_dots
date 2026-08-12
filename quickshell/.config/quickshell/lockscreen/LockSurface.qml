import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

	color: "#020403"

	// BACKGROUND IMAGE
	Image {
		anchors.fill: parent

		source: "lock.png"

		fillMode: Image.PreserveAspectCrop
		smooth: true
		mipmap: true
	}

	// dark overlay
	Rectangle {
		anchors.fill: parent
		color: "#000000"
		opacity: 0.35
	}

	// Ambient glow top left
	Rectangle {
		width: 700
		height: 700

		x: -250
		y: -250

		color: "#0d7a54"
		opacity: 0.05

		radius: width / 2

		layer.enabled: true
		layer.effect: MultiEffect {
			blurEnabled: true
			blur: 1.0
		}
	}

	// Ambient glow bottom right
	Rectangle {
		width: 600
		height: 600

		x: parent.width - 350
		y: parent.height - 350

		color: "#0b5c42"
		opacity: 0.04

		radius: width / 2

		layer.enabled: true
		layer.effect: MultiEffect {
			blurEnabled: true
			blur: 1.0
		}
	}

	// Scan lines
	Column {
		anchors.fill: parent
		spacing: 6
		opacity: 0.03

		Repeater {
			model: 300

			Rectangle {
				width: parent.width
				height: 1
				color: "#0d7a54"
			}
		}
	}

	// CLOCK
	Label {
		id: clock
		property var date: new Date()

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: 90
		}

		renderType: Text.NativeRendering

		font {
			family: "Share Tech Mono"
			pointSize: 78
			letterSpacing: 6
			bold: true
		}

		color: "#d7ffe9"

		style: Text.Outline
		styleColor: "#0d7a54"

		Timer {
			running: true
			repeat: true
			interval: 1000

			onTriggered: clock.date = new Date()
		}

		text: {
			const hours = this.date.getHours().toString().padStart(2, '0');
			const minutes = this.date.getMinutes().toString().padStart(2, '0');
			return `${hours}:${minutes}`;
		}
	}

	// DATE
	Label {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: clock.bottom
			topMargin: 6
		}

		font {
			family: "Share Tech Mono"
			pointSize: 16
			letterSpacing: 3
		}

		color: "#4d8c72"

		text: Qt.formatDateTime(clock.date, "dddd  |  MMMM d")
	}

	// MAIN PANEL
	Rectangle {
		id: panel

		width: 560
		height: 240

		anchors.centerIn: parent

		color: "#06100d"
		opacity: 0.82

		border.width: 2
		border.color: "#0d7a54"

		layer.enabled: true
		layer.effect: MultiEffect {
			shadowEnabled: true
			shadowColor: "#0d7a54"
			shadowBlur: 0.8
		}

		// corner accents
		Rectangle {
			width: 40
			height: 4
			color: "#0d7a54"

			anchors.top: parent.top
			anchors.left: parent.left
		}

		Rectangle {
			width: 4
			height: 40
			color: "#0d7a54"

			anchors.top: parent.top
			anchors.left: parent.left
		}

		Rectangle {
			width: 40
			height: 4
			color: "#0d7a54"

			anchors.bottom: parent.bottom
			anchors.right: parent.right
		}

		Rectangle {
			width: 4
			height: 40
			color: "#0d7a54"

			anchors.bottom: parent.bottom
			anchors.right: parent.right
		}

		// decorative lines
		Rectangle {
			width: 120
			height: 2

			color: "#0d7a54"
			opacity: 0.45

			anchors {
				top: parent.top
				right: parent.right
				topMargin: 18
				rightMargin: 20
			}
		}

		Rectangle {
			width: 90
			height: 2

			color: "#0d7a54"
			opacity: 0.45

			anchors {
				bottom: parent.bottom
				left: parent.left
				bottomMargin: 18
				leftMargin: 20
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 34

			spacing: 26

			Label {
				text: "AUTHENTICATION REQUIRED"

				font {
					family: "Share Tech Mono"
					pointSize: 22
					letterSpacing: 4
					bold: true
				}

				color: "#c6ffe3"

				Layout.alignment: Qt.AlignHCenter
			}

			RowLayout {
				spacing: 16

				TextField {
					id: passwordBox

					Layout.fillWidth: true

					implicitHeight: 58

					focus: true

					enabled: !root.context.unlockInProgress

					echoMode: TextInput.Password
					inputMethodHints: Qt.ImhSensitiveData

					padding: 14

					color: "#d7ffe9"

					font {
						family: "Share Tech Mono"
						pointSize: 15
						letterSpacing: 2
					}

					placeholderText: "ENTER PASSWORD"
					placeholderTextColor: "#467661"

					background: Rectangle {
						color: "#07110d"

						border.width: 2

						border.color: passwordBox.activeFocus
							? "#0d7a54"
							: "#184634"

						Rectangle {
							width: parent.width
							height: 2

							color: "#0d7a54"

							anchors.bottom: parent.bottom

							opacity: passwordBox.activeFocus ? 1 : 0.3
						}

						layer.enabled: true
						layer.effect: MultiEffect {
							shadowEnabled: true
							shadowColor: "#0d7a54"
							shadowBlur: 0.7
						}
					}

					onTextChanged: root.context.currentText = this.text
					onAccepted: root.context.tryUnlock()

					Connections {
						target: root.context

						function onCurrentTextChanged() {
							passwordBox.text = root.context.currentText
						}
					}
				}

				Button {
					text: "UNLOCK"

					implicitHeight: 58
					padding: 20

					focusPolicy: Qt.NoFocus

					enabled: !root.context.unlockInProgress
							 && root.context.currentText !== ""

					onClicked: root.context.tryUnlock()

					contentItem: Text {
						text: parent.text

						color: "#dfffee"

						font {
							family: "Share Tech Mono"
							pointSize: 13
							bold: true
							letterSpacing: 3
						}

						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}

					background: Rectangle {
						color: parent.pressed
							? "#0a5c40"
							: "#0d7a54"

						border.width: 2
						border.color: "#6cb69a"

						Rectangle {
							width: parent.width
							height: 2

							color: "#dfffee"
							opacity: 0.4

							anchors.top: parent.top
						}

						layer.enabled: true
						layer.effect: MultiEffect {
							shadowEnabled: true
							shadowColor: "#0d7a54"
							shadowBlur: 0.8
						}
					}
				}
			}

			Label {
				visible: root.context.showFailure

				text: "ACCESS DENIED"

				font {
					family: "Share Tech Mono"
					pointSize: 13
					bold: true
					letterSpacing: 4
				}

				color: "#d94b6c"

				Layout.alignment: Qt.AlignHCenter
			}
		}
	}

	// bottom label
	Label {
		text: "NEURAL INTERFACE SECURE LOCK"

		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
			bottomMargin: 24
		}

		font {
			family: "Share Tech Mono"
			pointSize: 11
			letterSpacing: 4
		}

		color: "#2f6953"
	}

	// emergency button
	Button {
		text: "EMERGENCY EXIT"

		anchors {
			right: parent.right
			bottom: parent.bottom
			rightMargin: 24
			bottomMargin: 24
		}

		opacity: 0.5

		onClicked: context.unlocked()

		contentItem: Text {
			text: parent.text

			color: "#6fa88f"

			font {
				family: "Share Tech Mono"
				pointSize: 10
				letterSpacing: 2
			}

			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}

		background: Rectangle {
			color: "#09120f"

			border.width: 1
			border.color: "#245743"
		}
	}
}
