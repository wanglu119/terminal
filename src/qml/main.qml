/*
 * Papyros Terminal - The terminal app for Papyros following Material Design
 * Copyright (C) 2016 Ricardo Vieira <ricardo.vieira@tecnico.ulisboa.pt>
 *               2016 Žiga Patačko Koderman <ziga.patacko@gmail.com>
 *               2016 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Window 2.2
import QMLTermWidget 1.0
import Material 0.2
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import Papyros.Core 0.2

ApplicationWindow {
    id: mainWindow

    title: mainsession.title
    visible: true

    theme {
        primaryColor: Palette.colors.blueGrey["800"]
        primaryDarkColor: Palette.colors.blueGrey["900"]
    }

    function pasteClipboard() {
        if (clipboard.text().indexOf("sudo") == 0 && settings.hideSudoWarning != "true") {
            sudoWarningDialog.show()
        } else {
            terminal.pasteClipboard()
        }
    }

    Component.onCompleted: terminal.forceActiveFocus();

    Action {
        shortcut: "Ctrl+Shift+C"
        onTriggered: terminal.copyClipboard();
    }

    Action {
        shortcut: "Ctrl+Shift+V"
        onTriggered: pasteClipboard()
    }

    // TODO: Implement search
    // Action {
    //     shortcut: "Ctrl+F"
    //     onTriggered: searchButton.visible = !searchButton.visible
    // }

    Action {
        shortcut: StandardKey.FullScreen

        onTriggered: {
            if (visibility === Window.Windowed) {
                showFullScreen()
            } else {
                showNormal()
            }
        }
    }

    Action {
        shortcut: StandardKey.ZoomIn
        onTriggered: settings.fontSize++
    }

    Action {
        shortcut: StandardKey.ZoomOut
        onTriggered: settings.fontSize--
    }

    initialPage: Page {
        title: "Terminal"

        actions: [
            // TODO: Only show when a physical keyboard is not available
            // Action {
            //     iconName: "content/content_paste"
            //     text: qsTr("Paste")
            //     shortcut: StandardKey.Paste
            //     onTriggered: pasteClipboard()
            // },
            // TODO: Renable when tabs support is added
            // Action {
            //     iconName: "content/add"
            //     text: qsTr("Open new tab")
            //     shortcut: StandardKey.AddTab
            //
            //     onTriggered: console.log("New tab");
            // },
            Action {
                iconName: "action/open_in_new"
                text: qsTr("Open new window")
                shortcut: "Ctrl+Shift+N"
                onTriggered: {
                    actionHandler.newWindow();
                    console.log("New window")
                }
            },
            Action {
                visible: wallet.enabled
                enabled: wallet.status == KQuickWallet.Open
                iconName: "communication/vpn_key"
                text: qsTr("Passwords")
                onTriggered: passwordsDialog.show()
            },
            // TODO: Implement search
            // Action {
            //     iconName: "action/search"
            //     text: qsTr("Search")
            // },
            Action {
                iconName: "action/settings"
                text: qsTr("Settings")
                onTriggered: settingsDialog.show();
            }
        ]

        QMLTermWidget {
            id: terminal

            anchors.centerIn: parent

            width: parent.width * Screen.devicePixelRatio + 2
            height: parent.height * Screen.devicePixelRatio + 2
            scale: 1/Screen.devicePixelRatio

            font.family: settings.fontFamily
            font.pointSize: settings.fontSize * Screen.devicePixelRatio
            colorScheme: "cool-retro-term"

            session: QMLTermSession {
                id: mainsession
                initialWorkingDirectory: "$HOME"
                shellProgram: settings.shellProgram
                onFinished: Qt.quit()
            }

            function insertText(text) {
                simulateKeyPress(0, Qt.NoModifier, true, 0, text);
            }

            Component.onCompleted: {
                mainsession.startShellProgram();
            }
        }
    }

    Clipboard {
        id: clipboard
    }

    Settings {
        id: settings
        // TODO: This is the way to do it, but the method is not invokable from QML
        // onOpacityChanged: terminal.setOpacity(opacity)
    }

    KQuickWallet {
        id: wallet

        folder: "Terminal Passwords"
    }

    PasswordsDialog {
        id: passwordsDialog
    }

    Dialog {
        id: sudoWarningDialog

        title: "This command is asking for administrative access to your computer"
        text: "Copying commands from the internet can be dangerous. Be sure you understand what this command does before running it:"

        positiveButtonText: "Paste Anyway"
        negativeButtonText: "Don't Paste"

        positiveButton.textColor: Palette.colors["red"]["500"]

        width: Units.dp(410)

        Item {
            width: parent.width
            height: textLabel.height

            Rectangle {
                id: bar
                width: Units.dp(3)
                height: parent.height
                radius: width/2
                color: textLabel.color
            }

            Label {
                id: textLabel

                anchors {
                    left: bar.right
                    right: parent.right
                    leftMargin: Units.dp(8)
                }

                wrapMode: Text.Wrap
                font.family: settings.fontFamily
                font.pixelSize: Units.dp(16)
                color: Theme.light.subTextColor
            }
        }

        onAccepted: terminal.pasteClipboard()

        onOpened: textLabel.text = clipboard.text().trim()
    }

    SettingsDialog {
        id: settingsDialog
    }
}
