#pragma once

#include "BluSDRDevice.h"

#include <QtCore/QObject>
#include <QtQml/QQmlListProperty>
#include <QtQmlIntegration/QtQmlIntegration>

class BluSDRManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QQmlListProperty<BluSDRDevice> devices READ devices NOTIFY devicesChanged)
    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY devicesChanged)
    Q_PROPERTY(bool anyDeviceConnected READ anyDeviceConnected NOTIFY connectionStatusChanged)

public:
    explicit BluSDRManager(QObject* parent = nullptr);
    ~BluSDRManager();

    static BluSDRManager* instance();
    static BluSDRManager* create(QQmlEngine*, QJSEngine*) { return instance(); }

    QQmlListProperty<BluSDRDevice> devices();
    int deviceCount() const { return _devices.count(); }
    bool anyDeviceConnected() const;

    Q_INVOKABLE void addDevice(const QString& name, const QString& ipAddress);
    Q_INVOKABLE void removeDevice(int index);
    Q_INVOKABLE BluSDRDevice* getDevice(int index);
    Q_INVOKABLE void startAllMonitoring();
    Q_INVOKABLE void stopAllMonitoring();
    Q_INVOKABLE void loadDefaultDevices();

signals:
    void devicesChanged();
    void connectionStatusChanged();

private:
    static qsizetype _devicesCount(QQmlListProperty<BluSDRDevice>* list);
    static BluSDRDevice* _devicesAt(QQmlListProperty<BluSDRDevice>* list, qsizetype index);

    QList<BluSDRDevice*> _devices;
};
