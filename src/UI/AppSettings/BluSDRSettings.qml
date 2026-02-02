import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactControls
import QGroundControl.Controls

SettingsPage {
    property var _bluSDRManager: QGroundControl.settingsManager.bluSDRManager

    Component.onCompleted: {
        console.log("✓ BluSDR Settings loaded")
        console.log("✓ Device count:", _bluSDRManager ? _bluSDRManager.deviceCount : "null")
    }

    SettingsGroupLayout {
        Layout.fillWidth: true
        heading: "BluSDR DashBoard"

        // 標題狀態指示器
        RowLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelWidth

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: "green"

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }

            QGCLabel {
                text: "Updating"
                color: qgcPal.colorGreen
            }

            Item { Layout.fillWidth: true }

            QGCLabel {
                text: "Find " + (_bluSDRManager ? _bluSDRManager.deviceCount : 0) + " Device"
                font.bold: true
            }
        }

        // Tips 說明區域 - 移到最上方
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: qgcPal.windowShade
            border.color: qgcPal.brandingBlue
            border.width: 2
            radius: 8

            Flickable {
                anchors.fill: parent
                anchors.margins: 18
                contentWidth: parent.width - 36
                contentHeight: tipsContent.implicitHeight
                clip: true

                ColumnLayout {
                    id: tipsContent
                    width: parent.width
                    spacing: 12

                    // 標題
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: qgcPal.brandingBlue

                            QGCLabel {
                                anchors.centerIn: parent
                                text: "i"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                                color: "white"
                            }
                        }

                        QGCLabel {
                            text: "Metrics Guide"
                            font.bold: true
                            font.pointSize: ScreenTools.largeFontPointSize
                        }
                    }

                    // 四個指標說明 - 橫向排列
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 4
                        columnSpacing: 20
                        rowSpacing: 8

                        // RSSI
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            QGCLabel {
                                text: "RSSI"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "> -70: Excellent"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorGreen
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "-70~-80: Good"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorOrange
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "< -80: Poor"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorRed
                                wrapMode: Text.WordWrap
                            }
                        }

                        // SNR
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            QGCLabel {
                                text: "SNR"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "> 20dB: Excellent"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorGreen
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "10~20dB: Good"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorOrange
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "< 10dB: Poor"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorRed
                                wrapMode: Text.WordWrap
                            }
                        }

                        // Temperature
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            QGCLabel {
                                text: "Temp"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "< 60°C: Normal"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorGreen
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "60~70°C: High"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorOrange
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "> 70°C: Overheat"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorRed
                                wrapMode: Text.WordWrap
                            }
                        }

                        // CPU
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            QGCLabel {
                                text: "CPU"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "< 60%: Normal"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorGreen
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "60~80%: Medium"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorOrange
                                wrapMode: Text.WordWrap
                            }
                            QGCLabel {
                                Layout.fillWidth: true
                                text: "> 80%: High Load"
                                font.pointSize: ScreenTools.defaultFontPointSize
                                color: qgcPal.colorRed
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }

        // 設備列表 - 使用 GridLayout 實現左右並列
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: ScreenTools.defaultFontPixelHeight
            columnSpacing: ScreenTools.defaultFontPixelWidth * 2

            Repeater {
                model: _bluSDRManager ? _bluSDRManager.deviceCount : 0

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: ScreenTools.defaultFontPixelHeight * 2.0

                    property var device: _bluSDRManager.getDevice(index)

                    // 設備標題卡片
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: deviceHeader.implicitHeight + 30
                        color: qgcPal.windowShade
                        border.color: device.connected ? qgcPal.colorGreen : qgcPal.colorRed
                        border.width: 2
                        radius: 5

                        ColumnLayout {
                            id: deviceHeader
                            width: parent.width
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8

                            QGCLabel {
                                Layout.fillWidth: true
                                text: device.name + " (" + device.ipAddress + ")"
                                font.bold: true
                                font.pointSize: ScreenTools.mediumFontPointSize
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: device.connected ? qgcPal.colorGreen : qgcPal.colorRed

                                    SequentialAnimation on scale {
                                        running: device.connected
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.3; duration: 500 }
                                        NumberAnimation { to: 1.0; duration: 500 }
                                    }
                                }

                                QGCLabel {
                                    text: device.connected ? "Connected" : "Not connected"
                                    color: device.connected ? qgcPal.colorGreen : qgcPal.colorRed
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    // 數據儀表板 (2x2 網格)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: ScreenTools.defaultFontPixelHeight * 1.5
                        columnSpacing: ScreenTools.defaultFontPixelWidth * 0.5

                        // RSSI 儀表
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            Layout.minimumWidth: 120
                            color: qgcPal.windowShade
                            border.color: qgcPal.text
                            border.width: 1
                            radius: 5

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 5

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "RSSI"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.rssiAverage.toFixed(1)
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: device.rssiAverage > -70 ? qgcPal.colorGreen :
                                           device.rssiAverage > -80 ? qgcPal.colorOrange : qgcPal.colorRed
                                }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "dBm"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    QGCLabel {
                                        Layout.fillWidth: true
                                        text: "A:" + device.rssiAntennaA.toFixed(0)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        elide: Text.ElideRight
                                    }

                                    QGCLabel {
                                        Layout.fillWidth: true
                                        text: "B:" + device.rssiAntennaB.toFixed(0)
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        horizontalAlignment: Text.AlignRight
                                        elide: Text.ElideLeft
                                    }
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: Math.max(0, Math.min(1, (device.rssiAverage + 100) / 60)) * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: device.rssiAverage > -70 ? qgcPal.colorGreen :
                                               device.rssiAverage > -80 ? qgcPal.colorOrange : qgcPal.colorRed
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        // SNR 儀表
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            Layout.minimumWidth: 120
                            color: qgcPal.windowShade
                            border.color: qgcPal.text
                            border.width: 1
                            radius: 5

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 5

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "SNR"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.snr.toFixed(1)
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: device.snr > 20 ? qgcPal.colorGreen :
                                           device.snr > 10 ? qgcPal.colorOrange : qgcPal.colorRed
                                }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "dB"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.snr > 20 ? "Excellent" : device.snr > 10 ? "Good" : "Poor"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: device.snr > 20 ? qgcPal.colorGreen :
                                           device.snr > 10 ? qgcPal.colorOrange : qgcPal.colorRed
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: Math.max(0, Math.min(1, device.snr / 40)) * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: device.snr > 20 ? qgcPal.colorGreen :
                                               device.snr > 10 ? qgcPal.colorOrange : qgcPal.colorRed
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        // 溫度儀表
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 170
                            Layout.minimumWidth: 120
                            color: qgcPal.windowShade
                            border.color: qgcPal.text
                            border.width: 1
                            radius: 5

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "Temperature"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.temperature.toFixed(1)
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: device.temperature > 70 ? qgcPal.colorRed :
                                           device.temperature > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "°C"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.temperature > 70 ? "Overheating" :
                                          device.temperature > 60 ? "High" : "Normal"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: device.temperature > 70 ? qgcPal.colorRed :
                                           device.temperature > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: Math.max(0, Math.min(1, device.temperature / 100)) * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: device.temperature > 70 ? qgcPal.colorRed :
                                               device.temperature > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        // CPU 使用率儀表
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 170
                            Layout.minimumWidth: 120
                            color: qgcPal.windowShade
                            border.color: qgcPal.text
                            border.width: 1
                            radius: 5

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "CPU"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.cpuUsage.toFixed(1)
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: device.cpuUsage > 80 ? qgcPal.colorRed :
                                           device.cpuUsage > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: "%"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Item { Layout.preferredHeight: 2 }

                                QGCLabel {
                                    Layout.fillWidth: true
                                    text: device.cpuUsage > 80 ? "High Load" :
                                          device.cpuUsage > 60 ? "Medium Load" : "Normal"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: device.cpuUsage > 80 ? qgcPal.colorRed :
                                           device.cpuUsage > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: Math.max(0, Math.min(1, device.cpuUsage / 100)) * parent.width
                                        height: parent.height
                                        radius: 3
                                        color: device.cpuUsage > 80 ? qgcPal.colorRed :
                                               device.cpuUsage > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }
                    }

                    // 底部狀態欄
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: qgcPal.windowShade
                        radius: 3

                        QGCLabel {
                            anchors.centerIn: parent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 5
                            text: "Latest update: " + device.lastUpdate
                            font.pointSize: ScreenTools.smallFontPointSize
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
