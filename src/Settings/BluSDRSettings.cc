#include "BluSDRSettings.h"

#include <QtQml/QQmlEngine>

DECLARE_SETTINGGROUP(BluSDR, "BluSDR")
{
    qmlRegisterUncreatableType<BluSDRSettings>("QGroundControl.SettingsManager", 1, 0, "BluSDRSettings", "Reference only");
}

DECLARE_SETTINGSFACT(BluSDRSettings, enabled)
DECLARE_SETTINGSFACT(BluSDRSettings, device1Enabled)
DECLARE_SETTINGSFACT(BluSDRSettings, device2Enabled)
DECLARE_SETTINGSFACT(BluSDRSettings, device1IP)
DECLARE_SETTINGSFACT(BluSDRSettings, device2IP)
DECLARE_SETTINGSFACT(BluSDRSettings, updateInterval)
