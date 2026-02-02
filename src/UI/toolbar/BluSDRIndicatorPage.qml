import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

Rectangle {
    id:     _root
    width:  mainLayout.width + (ScreenTools.defaultFontPixelWidth * 2)
    height: mainLayout.height + (ScreenTools.defaultFontPixelHeight * 2)
    radius: ScreenTools.defaultFontPixelHeight * 0.5
    color:  qgcPal.window

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    ColumnLayout {
        id:                 mainLayout
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelHeight * 0.5

        // 標題
        QGCLabel {
            text:               qsTr("BluSDR Status")
            font.pointSize:     ScreenTools.mediumFontPointSize
            font.bold:          true
            Layout.alignment:   Qt.AlignHCenter
        }

        Rectangle {
            height:             1
            Layout.fillWidth:   true
            color:              qgcPal.text
            opacity:            0.3
        }

        // 連線狀態
        GridLayout {
            columns:            2
            columnSpacing:      ScreenTools.defaultFontPixelWidth
            rowSpacing:         ScreenTools.defaultFontPixelHeight * 0.25

            QGCLabel { text: qsTr("Connection:") }
            QGCLabel {
                text:   qsTr("Connected")
                color:  "green"
                font.bold: true
            }

            QGCLabel { text: qsTr("Device:") }
            QGCLabel { text: "BluSDR v1.0" }

            QGCLabel { text: qsTr("Frequency:") }
            QGCLabel { text: "2.4 GHz" }

            QGCLabel { text: qsTr("Signal Strength:") }
            QGCLabel {
                text:   "-45 dBm"
                color:  "green"
            }

            QGCLabel { text: qsTr("Data Rate:") }
            QGCLabel { text: "1.2 Mbps" }
        }

        Rectangle {
            height:             1
            Layout.fillWidth:   true
            color:              qgcPal.text
            opacity:            0.3
        }

        // 按鈕區
        RowLayout {
            spacing:            ScreenTools.defaultFontPixelWidth
            Layout.alignment:   Qt.AlignHCenter

            QGCButton {
                text:       qsTr("Settings")
                onClicked: {
                    console.log("BluSDR Settings clicked")
                    // 未來可以打開設定頁面
                }
            }

            QGCButton {
                text:       qsTr("Reconnect")
                onClicked: {
                    console.log("BluSDR Reconnect clicked")
                    // 未來可以執行重新連線
                }
            }
        }
    }
}
