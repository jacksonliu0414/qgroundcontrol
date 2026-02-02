import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// BluSDR 訊號強度指示器（類似手機訊號）
Item {
    id: root
    width: signalBars.width
    height: signalBars.height

    property real rssi: -100  // RSSI 值
    property bool connected: false
    property int signalLevel: getSignalLevel(rssi)  // 0-5 格

    // 根據 RSSI 計算訊號格數
    function getSignalLevel(rssi) {
        if (!connected || rssi < -100) return 0
        if (rssi > -60) return 5  // 優秀
        if (rssi > -70) return 4  // 良好
        if (rssi > -80) return 3  // 中等
        if (rssi > -90) return 2  // 較弱
        if (rssi > -100) return 1 // 很弱
        return 0
    }

    // 根據訊號強度返回顏色
    function getSignalColor() {
        if (signalLevel >= 4) return "#00FF00"  // 綠色（強）
        if (signalLevel >= 2) return "#FFA500"  // 橙色（中）
        if (signalLevel >= 1) return "#FF4444"  // 紅色（弱）
        return "#666666"  // 灰色（無訊號）
    }

    Row {
        id: signalBars
        spacing: 1
        anchors.centerIn: parent

        // 5 格訊號條
        Repeater {
            model: 5

            Rectangle {
                width: 3
                height: 4 + index * 3  // 遞增高度：4, 7, 10, 13, 16
                color: index < signalLevel ? getSignalColor() : "#333333"
                radius: 1
                anchors.bottom: parent.bottom

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
