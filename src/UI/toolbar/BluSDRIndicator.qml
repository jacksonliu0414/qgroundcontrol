import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools

Item {
    id:             control
    width:          bluSDRRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: true  // 總是顯示
    property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    Component {
        id: bluSDRInfo

        BluSDRIndicatorPage { }
    }

    Row {
        id:             bluSDRRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        QGCColoredImage {
            id:                 bluSDRIcon
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/Satellite.svg"
            fillMode:           Image.PreserveAspectFit
            sourceSize.height:  height
            color:              qgcPal.windowTransparentText
        }

        QGCLabel {
            anchors.verticalCenter: parent.verticalCenter
            color:                  qgcPal.windowTransparentText
            text:                   "BluSDR"
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorDrawer(bluSDRInfo, control)
        }
    }
}
