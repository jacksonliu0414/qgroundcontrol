import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Rectangle {
    id: root
    implicitWidth:  mainLayout.width + (_margins * 2)
    implicitHeight: mainLayout.height + (_margins * 2)
    color:          qgcPal.window
    radius:         ScreenTools.defaultBorderRadius
    visible:        _bluSDRManager && _bluSDRManager.deviceCount > 0

    property var    _bluSDRManager: QGroundControl.settingsManager.bluSDRManager
    property real   _margins:       ScreenTools.defaultFontPixelWidth / 2
    property bool   showDetails:    false

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

    property color signalColor: {
        if (!anyConnected) return "#FF0000"
        if (averageRssi > -60) return "#00FF00"
        if (averageRssi > -80) return "#FFA500"
        return "#FF4444"
    }

    // 主要內容
    RowLayout {
        id:                 mainLayout
        anchors.margins:    _margins
        anchors.top:        parent.top
        anchors.left:       parent.left
        spacing:            _margins

        BluSDRSignalIndicator {
            rssi:       root.averageRssi
            connected:  root.anyConnected
            width:      ScreenTools.defaultFontPixelHeight * 1.2
            height:     ScreenTools.defaultFontPixelHeight
        }

        QGCLabel {
            text:               _bluSDRManager ? _bluSDRManager.deviceCount.toString() : "0"
            font.pointSize:     ScreenTools.mediumFontPointSize
            font.bold:          true
            color:              signalColor
        }
    }

    // 點擊區域
    MouseArea {
        anchors.fill: parent
        onClicked: root.showDetails = !root.showDetails
    }

    // 詳細資訊面板
    Popup {
        id: detailsPopup
        visible: root.showDetails
        x: parent.width - width
        y: parent.height + ScreenTools.defaultFontPixelHeight / 2
        width: ScreenTools.defaultFontPixelWidth * 28
        height: Math.min(contentLayout.implicitHeight + (_margins * 2), ScreenTools.availableHeight * 0.5)
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onClosed: root.showDetails = false

        background: Rectangle {
            color:          qgcPal.window
            border.color:   qgcPal.text
            border.width:   1
            radius:         ScreenTools.defaultBorderRadius
        }

        contentItem: ColumnLayout {
            id:         contentLayout
            spacing:    _margins

            // 標題列
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: _margins

                QGCLabel {
                    text:           "BluSDR Status"
                    font.bold:      true
                    font.pointSize: ScreenTools.mediumFontPointSize
                }

                Item { Layout.fillWidth: true }

                QGCButton {
                    text:                   "✕"
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 1.5
                    Layout.preferredHeight: Layout.preferredWidth
                    onClicked:              root.showDetails = false
                }
            }

            Rectangle {
                Layout.fillWidth:   true
                Layout.leftMargin:  _margins
                Layout.rightMargin: _margins
                height:             1
                color:              qgcPal.text
                opacity:            0.3
            }

            // 設備列表
            ScrollView {
                Layout.fillWidth:   true
                Layout.fillHeight:  true
                Layout.margins:     _margins
                clip:               true

                ColumnLayout {
                    width:      detailsPopup.width - (_margins * 4)
                    spacing:    _margins

                    Repeater {
                        model: _bluSDRManager ? _bluSDRManager.deviceCount : 0

                        Rectangle {
                            Layout.fillWidth:   true
                            implicitHeight:     deviceLayout.height + (_margins * 2)
                            color:              qgcPal.windowShade
                            radius:             ScreenTools.defaultBorderRadius

                            property var device: _bluSDRManager ? _bluSDRManager.getDevice(index) : null

                            ColumnLayout {
                                id:                 deviceLayout
                                anchors.margins:    _margins
                                anchors.top:        parent.top
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                spacing:            _margins / 2

                                // 設備名稱和狀態
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: _margins

                                    QGCLabel {
                                        text:           device ? device.name : ""
                                        font.bold:      true
                                        font.pointSize: ScreenTools.mediumFontPointSize
                                    }

                                    Rectangle {
                                        width:  ScreenTools.defaultFontPixelHeight * 0.6
                                        height: width
                                        radius: width / 2
                                        color:  device && device.connected ? "#00FF00" : "#FF0000"
                                    }

                                    Item { Layout.fillWidth: true }

                                    BluSDRSignalIndicator {
                                        rssi:       device ? device.rssiAverage : -100
                                        connected:  device ? device.connected : false
                                        width:      ScreenTools.defaultFontPixelHeight * 1.2
                                        height:     ScreenTools.defaultFontPixelHeight
                                    }
                                }

                                // 詳細資訊
                                GridLayout {
                                    Layout.fillWidth:   true
                                    columns:            2
                                    columnSpacing:      _margins
                                    rowSpacing:         _margins / 4
                                    visible:            device && device.connected

                                    QGCLabel {
                                        text:           "RSSI:"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                    }
                                    QGCLabel {
                                        text:           device ? device.rssiAverage.toFixed(1) + " dBm" : "N/A"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        font.bold:      true
                                        color: {
                                            if (!device) return qgcPal.text
                                            var rssi = device.rssiAverage
                                            if (rssi > -60) return "#00FF00"
                                            if (rssi > -80) return "#FFA500"
                                            return "#FF4444"
                                        }
                                    }

                                    QGCLabel {
                                        text:           "SNR:"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                    }
                                    QGCLabel {
                                        text:           device ? device.snr.toFixed(1) + " dB" : "N/A"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        font.bold:      true
                                    }

                                    QGCLabel {
                                        text:           "Temp:"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                    }
                                    QGCLabel {
                                        text:           device ? device.temperature.toFixed(1) + " °C" : "N/A"
                                        font.pointSize: ScreenTools.smallFontPointSize
                                        font.bold:      true
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
}
