import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// BluSDR 狀態顯示 Widget（可折疊）
Item {
    id: root
    width: expanded ? expandedWidth : collapsedWidth
    height: expanded ? detailsColumn.height + ScreenTools.defaultFontPixelHeight * 2 : collapsedHeight

    property var _bluSDRManager: QGroundControl.settingsManager.bluSDRManager
    property bool expanded: false  // 是否展開

    readonly property real collapsedWidth: ScreenTools.defaultFontPixelWidth * 10
    readonly property real collapsedHeight: ScreenTools.defaultFontPixelHeight * 2
    readonly property real expandedWidth: ScreenTools.defaultFontPixelWidth * 30

    // 計算平均 RSSI（用於顯示整體訊號強度）
    property real averageRssi: {
        if (!_bluSDRManager) return -100
        var sum = 0
        var count = 0
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

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

    // 背景
    Rectangle {
        anchors.fill: parent
        color: expanded ? "#E6000000" : "#B3000000"  // 展開時更不透明
        radius: ScreenTools.defaultFontPixelHeight * 0.5
        border.color: expanded ? "#80FFFFFF" : "#40FFFFFF"
        border.width: expanded ? 2 : 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    // 折疊狀態：只顯示訊號圖示
    MouseArea {
        anchors.fill: parent
        visible: !expanded
        onClicked: root.expanded = true

        RowLayout {
            anchors.centerIn: parent
            spacing: ScreenTools.defaultFontPixelWidth * 0.5

            // 訊號圖示
            BluSDRSignalIndicator {
                rssi: root.averageRssi
                connected: root.anyConnected
                Layout.preferredWidth: 20
                Layout.preferredHeight: 16
            }

            // 設備數量
            QGCLabel {
                text: _bluSDRManager ? _bluSDRManager.deviceCount.toString() : "0"
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold: true
                color: "white"
            }
        }
    }

    // 展開狀態：顯示詳細資訊
    ColumnLayout {
        id: detailsColumn
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelHeight * 0.5
        spacing: ScreenTools.defaultFontPixelHeight * 0.25
        visible: expanded

        // 標題列（含關閉按鈕）
        RowLayout {
            Layout.fillWidth: true

            QGCLabel {
                text: qsTr("BluSDR Status")
                font.bold: true
                font.pointSize: ScreenTools.mediumFontPointSize
                color: "white"
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
                width: ScreenTools.defaultFontPixelHeight * 1.5
                height: width
                onClicked: root.expanded = false
                background: Rectangle {
                    color: parent.pressed ? "#80FFFFFF" : "#40FFFFFF"
                    radius: width / 2
                }
            }
        }

        // 設備列表
        Repeater {
            model: _bluSDRManager ? _bluSDRManager.deviceCount : 0

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                property var device: _bluSDRManager ? _bluSDRManager.getDevice(index) : null

                // 分隔線
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#80FFFFFF"
                    visible: index > 0
                }

                // 設備名稱 + 連接狀態 + 訊號圖示
                RowLayout {
                    Layout.fillWidth: true
                    spacing: ScreenTools.defaultFontPixelWidth * 0.5

                    QGCLabel {
                        text: device ? device.name : ""
                        font.bold: true
                        font.pointSize: ScreenTools.mediumFontPointSize
                        color: "white"
                    }

                    Rectangle {
                        width: ScreenTools.defaultFontPixelHeight * 0.8
                        height: width
                        radius: width / 2
                        color: device && device.connected ? "#00FF00" : "#FF0000"
                        border.color: "white"
                        border.width: 1
                    }

                    Item { Layout.fillWidth: true }

                    // 單個設備的訊號圖示
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
                        color: "#CCCCCC"
                    }
                    QGCLabel {
                        text: device ? device.rssiAverage.toFixed(1) + " dBm" : "N/A"
                        font.pointSize: ScreenTools.smallFontPointSize
                        font.bold: true
                        color: {
                            if (!device) return "white"
                            var rssi = device.rssiAverage
                            if (rssi > -60) return "#00FF00"
                            if (rssi > -80) return "#FFA500"
                            return "#FF4444"
                        }
                    }

                    QGCLabel {
                        text: qsTr("SNR:")
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: "#CCCCCC"
                    }
                    QGCLabel {
                        text: device ? device.snr.toFixed(1) + " dB" : "N/A"
                        font.pointSize: ScreenTools.smallFontPointSize
                        font.bold: true
                        color: "white"
                    }

                    QGCLabel {
                        text: qsTr("Temp:")
                        font.pointSize: ScreenTools.smallFontPointSize
                        color: "#CCCCCC"
                    }
                    QGCLabel {
                        text: device ? device.temperature.toFixed(1) + " °C" : "N/A"
                        font.pointSize: ScreenTools.smallFontPointSize
                        font.bold: true
                        color: {
                            if (!device) return "white"
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
