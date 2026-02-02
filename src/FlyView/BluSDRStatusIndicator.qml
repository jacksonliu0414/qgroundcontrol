import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// BluSDR 狀態指示器（底部狀態欄專用）
Rectangle {
    id: root
    width: contentRow.width + ScreenTools.defaultFontPixelWidth
    height: contentRow.height + ScreenTools.defaultFontPixelHeight * 0.5
    color: qgcPal.window
    radius: ScreenTools.defaultFontPixelWidth / 2
    opacity: 0.75

    property var _bluSDRManager: QGroundControl.settingsManager.bluSDRManager
    property bool showDetails: false

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    // 計算平均 RSSI
    property real averageRssi: {
        if (!_bluSDRManager) return -100
        var sum = 0, count = 0
        for (var i = 0; i < _bluSDRManager.deviceCount; i++) {
            var device = _bluSDRManager.getDevice(i)
            if (device && device.connected && device.enabled) {
                sum += device.rssiAverage
                count++
            }
        }
        return count > 0 ? sum / count : -100
    }

    property bool anyConnected: {
        if (!_bluSDRManager) return false
        for (var i = 0; i < _bluSDRManager.deviceCount; i++) {
            var device = _bluSDRManager.getDevice(i)
            if (device && device.connected) return true
        }
        return false
    }

    // 主要內容
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: ScreenTools.defaultFontPixelWidth * 0.5

        // 訊號圖示
        BluSDRSignalIndicator {
            id: signalIndicator
            rssi: root.averageRssi
            connected: root.anyConnected
            Layout.preferredWidth: 20
            Layout.preferredHeight: 16
        }

        // 設備數量
        QGCLabel {
            text: _bluSDRManager ? _bluSDRManager.deviceCount.toString() : "0"
            font.pointSize: ScreenTools.mediumFontPointSize
            color: qgcPal.text
        }
    }

    // 點擊區域
    MouseArea {
        anchors.fill: parent
        onClicked: root.showDetails = !root.showDetails
    }

    // 詳細資訊彈出面板（向上彈出）
    Rectangle {
        id: detailsPanel
        visible: root.showDetails
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.bottomMargin: ScreenTools.defaultFontPixelHeight * 0.5
        width: ScreenTools.defaultFontPixelWidth * 30
        height: Math.min(detailsColumn.implicitHeight + ScreenTools.defaultFontPixelHeight, 
                        ScreenTools.availableHeight * 0.5)
        color: qgcPal.window
        radius: ScreenTools.defaultFontPixelHeight * 0.5
        border.color: qgcPal.text
        border.width: 1
        opacity: 0.95
        z: QGroundControl.zOrderWidgets + 100

        // 防止點擊穿透
        MouseArea {
            anchors.fill: parent
            onClicked: {} // 阻止事件傳播
        }

        ColumnLayout {
            id: detailsColumn
            anchors.fill: parent
            anchors.margins: ScreenTools.defaultFontPixelHeight * 0.5
            spacing: ScreenTools.defaultFontPixelHeight * 0.25

            // 標題列
            RowLayout {
                Layout.fillWidth: true

                QGCLabel {
                    text: qsTr("BluSDR Status")
                    font.bold: true
                    font.pointSize: ScreenTools.mediumFontPointSize
                }

                Item { Layout.fillWidth: true }

                // 訊號圖示
                BluSDRSignalIndicator {
                    rssi: root.averageRssi
                    connected: root.anyConnected
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 16
                }

                // 關閉按鈕
                QGCButton {
                    text: "✕"
                    Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.preferredHeight: Layout.preferredWidth
                    padding: 0
                    onClicked: root.showDetails = false
                }
            }

            // 分隔線
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: qgcPal.text
                opacity: 0.3
            }

            // 設備列表（可滾動）
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: detailsPanel.width - ScreenTools.defaultFontPixelHeight
                    spacing: ScreenTools.defaultFontPixelHeight * 0.5

                    Repeater {
                        model: _bluSDRManager ? _bluSDRManager.deviceCount : 0

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            property var device: _bluSDRManager ? _bluSDRManager.getDevice(index) : null

                            // 設備分隔線
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: qgcPal.text
                                opacity: 0.2
                                visible: index > 0
                            }

                            // 設備名稱 + 狀態
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: ScreenTools.defaultFontPixelWidth * 0.5

                                QGCLabel {
                                    text: device ? device.name : ""
                                    font.bold: true
                                    font.pointSize: ScreenTools.mediumFontPointSize
                                }

                                Rectangle {
                                    width: ScreenTools.defaultFontPixelHeight * 0.8
                                    height: width
                                    radius: width / 2
                                    color: device && device.connected ? "#00FF00" : "#FF0000"
                                    border.color: qgcPal.text
                                    border.width: 1
                                }

                                Item { Layout.fillWidth: true }

                                BluSDRSignalIndicator {
                                    rssi: device ? device.rssiAverage : -100
                                    connected: device ? device.connected : false
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 16
                                }
                            }

                            // 詳細資訊
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: ScreenTools.defaultFontPixelWidth
                                rowSpacing: 2
                                visible: device && device.connected && device.enabled

                                QGCLabel {
                                    text: qsTr("RSSI:")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    opacity: 0.8
                                }
                                QGCLabel {
                                    text: device ? device.rssiAverage.toFixed(1) + " dBm" : "N/A"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    font.bold: true
                                    color: {
                                        if (!device) return qgcPal.text
                                        var rssi = device.rssiAverage
                                        if (rssi > -60) return "#00FF00"
                                        if (rssi > -80) return "#FFA500"
                                        return "#FF4444"
                                    }
                                }

                                QGCLabel {
                                    text: qsTr("SNR:")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    opacity: 0.8
                                }
                                QGCLabel {
                                    text: device ? device.snr.toFixed(1) + " dB" : "N/A"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    font.bold: true
                                }

                                QGCLabel {
                                    text: qsTr("Temp:")
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    opacity: 0.8
                                }
                                QGCLabel {
                                    text: device ? device.temperature.toFixed(1) + " °C" : "N/A"
                                    font.pointSize: ScreenTools.smallFontPointSize
                                    font.bold: true
                                    color: {
                                        if (!device) return qgcPal.text
                                        var temp = device.temperature
                                        if (temp > 70) return "#FF4444"
                                        if (temp > 50) return "#FFA500"
                                        return "#00FF00"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
