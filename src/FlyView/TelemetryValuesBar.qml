import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Item {
    id:             control
    implicitWidth:  mainLayout.width + (_toolsMargin * 2)
    implicitHeight: mainLayout.height + (_toolsMargin * 2)

    property real extraWidth: 0 ///< Extra width to add to the background rectangle

    property alias factValueGrid:           factValueGrid
    property alias settingsGroup:           factValueGrid.settingsGroup
    property alias specificVehicleForCard:  factValueGrid.specificVehicleForCard

    // BluSDR 相關屬性
    property var _bluSDRManager: QGroundControl.settingsManager.bluSDRManager
    property bool _bluSDRAvailable: _bluSDRManager && _bluSDRManager.deviceCount > 0

    Rectangle {
        id:         backgroundRect
        width:      control.width + extraWidth
        height:     control.height
        color:      qgcPal.window
        radius:     ScreenTools.defaultFontPixelWidth / 2
        opacity:    0.75
    }

    ColumnLayout {
        id:                 mainLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

        RowLayout {
            visible: factValueGrid.settingsUnlocked

            QGCColoredImage {
                source:             "qrc:/InstrumentValueIcons/lock-open.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.text
                fillMode:           Image.PreserveAspectFit

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    factValueGrid.settingsUnlocked = false
                }
            }
        }

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth

            HorizontalFactValueGrid {
                id: factValueGrid
            }

            // BluSDR 訊號指示器（在遙測數據右側）
            Item {
                id: bluSDRIndicatorItem
                visible: _bluSDRAvailable && !factValueGrid.settingsUnlocked
                Layout.preferredWidth: bluSDRRow.width
                Layout.preferredHeight: factValueGrid.height

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

                property bool showDetails: false

                RowLayout {
                    id: bluSDRRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: ScreenTools.defaultFontPixelWidth * 0.5

                    // 訊號強度圖示
                    BluSDRSignalIndicator {
                        id: signalIndicator
                        rssi: bluSDRIndicatorItem.averageRssi
                        connected: bluSDRIndicatorItem.anyConnected
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
                QGCMouseArea {
                    anchors.fill: parent
                    onClicked: bluSDRIndicatorItem.showDetails = !bluSDRIndicatorItem.showDetails
                }

                // 詳細資訊彈出面板
                Rectangle {
                    id: detailsPanel
                    visible: bluSDRIndicatorItem.showDetails
                    anchors.top: parent.bottom
                    anchors.right: parent.right
                    anchors.topMargin: ScreenTools.defaultFontPixelHeight * 0.5
                    width: ScreenTools.defaultFontPixelWidth * 30
                    height: detailsColumn.height + ScreenTools.defaultFontPixelHeight
                    color: qgcPal.window
                    radius: ScreenTools.defaultFontPixelHeight * 0.5
                    border.color: qgcPal.text
                    border.width: 1
                    z: QGroundControl.zOrderWidgets + 10

                    // 關閉面板的透明區域
                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: false
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
                                rssi: bluSDRIndicatorItem.averageRssi
                                connected: bluSDRIndicatorItem.anyConnected
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 16
                            }

                            // 關閉按鈕
                            QGCButton {
                                text: "✕"
                                Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 1.5
                                Layout.preferredHeight: Layout.preferredWidth
                                onClicked: bluSDRIndicatorItem.showDetails = false
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
                                    color: qgcPal.text
                                    opacity: 0.3
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

    QGCMouseArea {
        id:                         mouseArea
        x:                          mainLayout.x
        y:                          mainLayout.y
        width:                      mainLayout.width
        height:                     mainLayout.height
        acceptedButtons:            Qt.LeftButton | Qt.RightButton
        propagateComposedEvents:    true
        visible:                    !factValueGrid.settingsUnlocked

        onClicked: (mouse) => {
            if (!ScreenTools.isMobile && mouse.button === Qt.RightButton) {
                factValueGrid.settingsUnlocked = true
                mouse.accepted = true
            }
        }

        onPressAndHold: {
            factValueGrid.settingsUnlocked = true
            mouse.accepted = true
        }
    }
}
