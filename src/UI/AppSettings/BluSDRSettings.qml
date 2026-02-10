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

        // Tips 說明區域
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

                    // 四個指標說明
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

        // 設備列表 - 左右並列
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
                    spacing: ScreenTools.defaultFontPixelHeight * 1.5

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
                                    text: device.connected ? device.rssiAverage.toFixed(1) : "N/A"
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: !device.connected ? qgcPal.text :
                                           device.rssiAverage > -70 ? qgcPal.colorGreen :
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
                                    visible: device.connected

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

                                QGCLabel {
                                    Layout.fillWidth: true
                                    visible: !device.connected
                                    text: "Poor"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: qgcPal.colorRed
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: device.connected ? Math.max(0, Math.min(1, (device.rssiAverage + 100) / 60)) * parent.width : parent.width
                                        height: parent.height
                                        radius: 3
                                        color: !device.connected ? qgcPal.colorRed :
                                               device.rssiAverage > -70 ? qgcPal.colorGreen :
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
                                    text: device.connected ? device.snr.toFixed(1) : "N/A"
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: !device.connected ? qgcPal.text :
                                           device.snr > 20 ? qgcPal.colorGreen :
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
                                    text: !device.connected ? "Poor" :
                                          device.snr > 20 ? "Excellent" :
                                          device.snr > 10 ? "Good" : "Poor"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: !device.connected ? qgcPal.colorRed :
                                           device.snr > 20 ? qgcPal.colorGreen :
                                           device.snr > 10 ? qgcPal.colorOrange : qgcPal.colorRed
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: device.connected ? Math.max(0, Math.min(1, device.snr / 40)) * parent.width : parent.width
                                        height: parent.height
                                        radius: 3
                                        color: !device.connected ? qgcPal.colorRed :
                                               device.snr > 20 ? qgcPal.colorGreen :
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
                                    text: device.connected ? device.temperature.toFixed(1) : "N/A"
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: !device.connected ? qgcPal.text :
                                           device.temperature > 70 ? qgcPal.colorRed :
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
                                    text: !device.connected ? "Normal" :
                                          device.temperature > 70 ? "Overheating" :
                                          device.temperature > 60 ? "High" : "Normal"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: !device.connected ? qgcPal.text :
                                           device.temperature > 70 ? qgcPal.colorRed :
                                           device.temperature > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: device.connected ? Math.max(0, Math.min(1, device.temperature / 100)) * parent.width : 0
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
                                    text: device.connected ? device.cpuUsage.toFixed(1) : "N/A"
                                    font.pointSize: ScreenTools.largeFontPointSize * 1.2
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    color: !device.connected ? qgcPal.text :
                                           device.cpuUsage > 80 ? qgcPal.colorRed :
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
                                    text: !device.connected ? "Normal" :
                                          device.cpuUsage > 80 ? "High Load" :
                                          device.cpuUsage > 60 ? "Medium Load" : "Normal"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    horizontalAlignment: Text.AlignHCenter
                                    color: !device.connected ? qgcPal.text :
                                           device.cpuUsage > 80 ? qgcPal.colorRed :
                                           device.cpuUsage > 60 ? qgcPal.colorOrange : qgcPal.colorGreen
                                }

                                Item { Layout.preferredHeight: 2 }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 6
                                    color: qgcPal.window
                                    radius: 3

                                    Rectangle {
                                        width: device.connected ? Math.max(0, Math.min(1, device.cpuUsage / 100)) * parent.width : 0
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

                    // 替換原本的 TX 輸出功率控制區域
                    Rectangle {
                        id: txPowerControl
                        Layout.fillWidth: true
                        Layout.preferredHeight: txExpanded ? 105 : 32  // ⭐ 增加高度
                        color: qgcPal.windowShade
                        border.color: device.connected ? qgcPal.brandingBlue : qgcPal.text
                        border.width: 1
                        radius: 5
                        opacity: device.connected ? 1.0 : 0.5
                        clip: true

                        property bool txExpanded: false

                        Behavior on Layout.preferredHeight {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10  // ⭐ 增加邊距從 8 到 10
                            spacing: 6

                            // 可點擊的標題列
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                color: titleMouseArea.containsMouse ? Qt.rgba(qgcPal.buttonHighlight.r, qgcPal.buttonHighlight.g, qgcPal.buttonHighlight.b, 0.3) : "transparent"
                                radius: 3

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 3
                                    anchors.rightMargin: 3
                                    spacing: 5

                                    QGCLabel {
                                        text: (txPowerControl.txExpanded ? "▼" : "▶") + " TX Power: " +
                                              (device.connected ? device.outputAttenuation.toFixed(1) + "dB" : "N/A")
                                        font.bold: true
                                        font.pointSize: ScreenTools.smallFontPointSize
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                MouseArea {
                                    id: titleMouseArea
                                    anchors.fill: parent
                                    enabled: device.connected
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        txPowerControl.txExpanded = !txPowerControl.txExpanded
                                    }
                                }
                            }

                            // 展開的控制區域
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: txPowerControl.txExpanded && device.connected
                                spacing: 6

                                // 滑桿
                                Slider {
                                    id: attenuationSlider
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 3
                                    Layout.rightMargin: 3
                                    from: 0
                                    to: 32
                                    stepSize: 0.5
                                    value: device.outputAttenuation

                                    onPressedChanged: {
                                        if (!pressed) {
                                            device.setOutputAttenuation(value, device.currentConfig)
                                        }
                                    }

                                    background: Rectangle {
                                        x: attenuationSlider.leftPadding
                                        y: attenuationSlider.topPadding + attenuationSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 200
                                        implicitHeight: 4
                                        width: attenuationSlider.availableWidth
                                        height: implicitHeight
                                        radius: 2
                                        color: qgcPal.window

                                        Rectangle {
                                            width: attenuationSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: attenuationSlider.value > 20 ? qgcPal.colorRed :
                                                   attenuationSlider.value > 10 ? qgcPal.colorOrange : qgcPal.colorGreen
                                            radius: 2
                                        }
                                    }

                                    handle: Rectangle {
                                        x: attenuationSlider.leftPadding + attenuationSlider.visualPosition * (attenuationSlider.availableWidth - width)
                                        y: attenuationSlider.topPadding + attenuationSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 16
                                        implicitHeight: 16
                                        radius: 8
                                        color: attenuationSlider.pressed ? qgcPal.buttonHighlight : qgcPal.button
                                        border.color: qgcPal.text
                                        border.width: 1
                                    }
                                }

                                // 快捷按鈕
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 2  // ⭐ 新增：與滑桿的間距
                                    Layout.bottomMargin: 8  // ⭐ 新增：與底部的間距
                                    spacing: 5

                                    QGCTextField {
                                        id: attenuationInput
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 26
                                        text: device.outputAttenuation.toFixed(1)
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        horizontalAlignment: Text.AlignHCenter

                                        onEditingFinished: {
                                            var value = parseFloat(text)
                                            if (!isNaN(value) && value >= 0 && value <= 32) {
                                                device.setOutputAttenuation(value, device.currentConfig)
                                            } else {
                                                text = device.outputAttenuation.toFixed(1)
                                            }
                                        }
                                    }

                                    QGCLabel {
                                        text: "dB"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Max 按鈕
                                    Item {
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 26

                                        Rectangle {
                                            anchors.fill: parent
                                            color: {
                                                if (maxMouseArea.pressed) {
                                                    return "#4A90E2"
                                                } else if (maxMouseArea.containsMouse) {
                                                    return "#5A5A5A"
                                                } else {
                                                    return "#404040"
                                                }
                                            }
                                            border.color: "#808080"
                                            border.width: 1
                                            radius: 3

                                            QGCLabel {
                                                anchors.centerIn: parent
                                                text: "Max"
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color: "white"
                                            }

                                            MouseArea {
                                                id: maxMouseArea
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: device.setOutputAttenuation(0, device.currentConfig)
                                            }
                                        }
                                    }

                                    // Min 按鈕
                                    Item {
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 26

                                        Rectangle {
                                            anchors.fill: parent
                                            color: {
                                                if (minMouseArea.pressed) {
                                                    return "#4A90E2"
                                                } else if (minMouseArea.containsMouse) {
                                                    return "#5A5A5A"
                                                } else {
                                                    return "#404040"
                                                }
                                            }
                                            border.color: "#808080"
                                            border.width: 1
                                            radius: 3

                                            QGCLabel {
                                                anchors.centerIn: parent
                                                text: "Min"
                                                font.pointSize: ScreenTools.smallFontPointSize
                                                color: "white"
                                            }

                                            MouseArea {
                                                id: minMouseArea
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: device.setOutputAttenuation(32, device.currentConfig)
                                            }
                                        }
                                    }
                                }

                                // 狀態提示
                                QGCLabel {
                                    Layout.fillWidth: true
                                    visible: device.settingAttenuation || device.outputAttenuation < 5
                                    text: device.settingAttenuation ? "⏳ Setting..." : "⚠ High power"
                                    color: device.settingAttenuation ? qgcPal.colorOrange : qgcPal.colorRed
                                    font.pointSize: ScreenTools.smallFontPointSize * 0.85
                                    font.italic: true
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }
                            }

                            // 未連線提示
                            QGCLabel {
                                Layout.fillWidth: true
                                visible: !device.connected
                                text: "Device not connected"
                                color: qgcPal.colorRed
                                font.pointSize: ScreenTools.smallFontPointSize
                                font.italic: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Connections {
                            target: device
                            function onAttenuationSetSuccess(value) {
                                successPopup.show()
                            }
                            function onAttenuationSetFailed(error) {
                                errorPopup.errorMessage = error
                                errorPopup.show()
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
                            text: device.connected ? ("Latest update: " + device.lastUpdate) : "Disconnected"
                            font.pointSize: ScreenTools.smallFontPointSize
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: device.connected ? qgcPal.text : qgcPal.colorRed
                        }
                    }
                }
            }
        }
    }

    // 成功提示
    Rectangle {
        id: successPopup
        width: 250
        height: 60
        color: qgcPal.colorGreen
        radius: 5
        opacity: 0
        visible: opacity > 0
        anchors.centerIn: parent
        z: 1000

        function show() {
            opacity = 1
            hideTimer.start()
        }

        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: successPopup.opacity = 0
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        QGCLabel {
            anchors.centerIn: parent
            text: "✓ Attenuation set successfully"
            color: "white"
            font.bold: true
        }
    }

    // 錯誤提示
    Rectangle {
        id: errorPopup
        width: 300
        height: 80
        color: qgcPal.colorRed
        radius: 5
        opacity: 0
        visible: opacity > 0
        anchors.centerIn: parent
        z: 1000

        property string errorMessage: ""

        function show() {
            opacity = 1
            errorHideTimer.start()
        }

        Timer {
            id: errorHideTimer
            interval: 3000
            onTriggered: errorPopup.opacity = 0
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: "✗ Failed to set attenuation"
                color: "white"
                font.bold: true
            }

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: errorPopup.errorMessage
                color: "white"
                font.pointSize: ScreenTools.smallFontPointSize
                wrapMode: Text.WordWrap
            }
        }
    }
}
