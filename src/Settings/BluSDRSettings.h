#pragma once

#include "SettingsGroup.h"

class BluSDRSettings : public SettingsGroup
{
    Q_OBJECT

public:
    BluSDRSettings(QObject* parent = nullptr);

    DEFINE_SETTING_NAME_GROUP()

    DEFINE_SETTINGFACT(enabled)
    DEFINE_SETTINGFACT(device1Enabled)
    DEFINE_SETTINGFACT(device2Enabled)
    DEFINE_SETTINGFACT(device1IP)
    DEFINE_SETTINGFACT(device2IP)
    DEFINE_SETTINGFACT(updateInterval)
};
