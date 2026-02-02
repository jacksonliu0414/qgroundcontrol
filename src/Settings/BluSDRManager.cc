#include "BluSDRManager.h"

#include <QtCore/QDebug>

static BluSDRManager* _instance = nullptr;

BluSDRManager::BluSDRManager(QObject* parent)
    : QObject(parent)
{
    _instance = this;
    loadDefaultDevices();
}

BluSDRManager::~BluSDRManager()
{
    stopAllMonitoring();
    qDeleteAll(_devices);
    _devices.clear();
}

BluSDRManager* BluSDRManager::instance()
{
    return _instance;
}

QQmlListProperty<BluSDRDevice> BluSDRManager::devices()
{
    return QQmlListProperty<BluSDRDevice>(
        this,
        nullptr,
        &BluSDRManager::_devicesCount,
        &BluSDRManager::_devicesAt
    );
}

bool BluSDRManager::anyDeviceConnected() const
{
    for (const auto* device : _devices) {
        if (device->connected()) {
            return true;
        }
    }
    return false;
}

void BluSDRManager::addDevice(const QString& name, const QString& ipAddress)
{
    auto* device = new BluSDRDevice(name, ipAddress, this);
    
    connect(device, &BluSDRDevice::connectedChanged, this, &BluSDRManager::connectionStatusChanged);
    
    _devices.append(device);
    emit devicesChanged();
    
    qDebug() << "BluSDR: Added device" << name << "at" << ipAddress;
}

void BluSDRManager::removeDevice(int index)
{
    if (index >= 0 && index < _devices.count()) {
        BluSDRDevice* device = _devices.takeAt(index);
        device->stopMonitoring();
        device->deleteLater();
        emit devicesChanged();
    }
}

BluSDRDevice* BluSDRManager::getDevice(int index)
{
    if (index >= 0 && index < _devices.count()) {
        return _devices.at(index);
    }
    return nullptr;
}

void BluSDRManager::startAllMonitoring()
{
    qDebug() << "BluSDR: Starting monitoring for all devices";
    for (auto* device : _devices) {
        if (device->enabled()) {
            device->startMonitoring();
        }
    }
}

void BluSDRManager::stopAllMonitoring()
{
    qDebug() << "BluSDR: Stopping monitoring for all devices";
    for (auto* device : _devices) {
        device->stopMonitoring();
    }
}

void BluSDRManager::loadDefaultDevices()
{
    addDevice("GCS", "192.168.0.12");
    addDevice("LM", "192.168.0.13");
    
    if (_devices.count() >= 2) {
        _devices[0]->setEnabled(true);
        _devices[1]->setEnabled(true);
    }
}

qsizetype BluSDRManager::_devicesCount(QQmlListProperty<BluSDRDevice>* list)
{
    BluSDRManager* manager = qobject_cast<BluSDRManager*>(list->object);
    return manager ? manager->_devices.count() : 0;
}

BluSDRDevice* BluSDRManager::_devicesAt(QQmlListProperty<BluSDRDevice>* list, qsizetype index)
{
    BluSDRManager* manager = qobject_cast<BluSDRManager*>(list->object);
    return (manager && index >= 0 && index < manager->_devices.count()) ? manager->_devices.at(index) : nullptr;
}
