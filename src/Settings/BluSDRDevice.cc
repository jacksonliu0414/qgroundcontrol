#include "BluSDRDevice.h"

#include <QtCore/QDebug>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonArray>
#include <QtCore/QDateTime>
#include <QtNetwork/QNetworkRequest>

BluSDRDevice::BluSDRDevice(const QString& name, const QString& ipAddress, QObject* parent)
    : QObject(parent)
    , _name(name)
    , _ipAddress(ipAddress)
{
    _networkManager = new QNetworkAccessManager(this);
    _updateTimer = new QTimer(this);
    _updateTimer->setInterval(UPDATE_INTERVAL_MS);
    
    connect(_updateTimer, &QTimer::timeout, this, &BluSDRDevice::_updateTimerFired);
}

BluSDRDevice::~BluSDRDevice()
{
    stopMonitoring();
}

void BluSDRDevice::setName(const QString& name)
{
    if (_name != name) {
        _name = name;
        emit nameChanged();
    }
}

void BluSDRDevice::setIpAddress(const QString& ip)
{
    if (_ipAddress != ip) {
        _ipAddress = ip;
        emit ipAddressChanged();
    }
}

void BluSDRDevice::setEnabled(bool enabled)
{
    if (_enabled != enabled) {
        _enabled = enabled;
        emit enabledChanged();
        
        if (_enabled) {
            startMonitoring();
        } else {
            stopMonitoring();
        }
    }
}

void BluSDRDevice::setUsername(const QString& username)
{
    if (_username != username) {
        _username = username;
        emit usernameChanged();
    }
}

void BluSDRDevice::setPassword(const QString& password)
{
    if (_password != password) {
        _password = password;
        emit passwordChanged();
    }
}

void BluSDRDevice::startMonitoring()
{
    qDebug() << "BluSDR: Starting monitoring for" << _name << "at" << _ipAddress;
    _updateTimer->start();
    _fetchData();
}

void BluSDRDevice::stopMonitoring()
{
    qDebug() << "BluSDR: Stopping monitoring for" << _name;
    _updateTimer->stop();
    _setConnected(false);
}

void BluSDRDevice::refreshData()
{
    _fetchData();
}

QNetworkRequest BluSDRDevice::_createAuthenticatedRequest(const QString& endpoint)
{
    QUrl url(QString("http://%1/%2").arg(_ipAddress, endpoint));
    QNetworkRequest request(url);
    
    QString credentials = QString("%1:%2").arg(_username, _password);
    QByteArray encodedCredentials = credentials.toUtf8().toBase64();
    QString authHeader = "Basic " + encodedCredentials;
    request.setRawHeader("Authorization", authHeader.toUtf8());
    
    request.setHeader(QNetworkRequest::UserAgentHeader, "QGroundControl");
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
    
    return request;
}

void BluSDRDevice::_fetchData()
{
    if (_ipAddress.isEmpty()) {
        return;
    }
    
    QNetworkRequest statusRequest = _createAuthenticatedRequest("status.json");
    QNetworkReply* statusReply = _networkManager->get(statusRequest);
    connect(statusReply, &QNetworkReply::finished, this, &BluSDRDevice::_onStatusReplyFinished);
}

void BluSDRDevice::_onStatusReplyFinished()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    reply->deleteLater();
    
    if (reply->error() == QNetworkReply::NoError) {
        _parseStatusJson(reply->readAll());
        _setConnected(true);
    } else {
        qWarning() << "BluSDR: Error fetching status from" << _name << ":" << reply->errorString();
        if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
            qWarning() << "BluSDR: Authentication failed for" << _name;
        }
        _setConnected(false);
    }
}

void BluSDRDevice::_parseStatusJson(const QByteArray& data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        qWarning() << "BluSDR: Invalid status JSON from" << _name;
        return;
    }
    
    QJsonObject root = doc.object();
    QJsonObject status = root.value("Status").toObject();
    
    // 溫度
    _temperature = status.value("Temperature").toDouble();
    
    // CPU 使用率
    QJsonObject cpuUsage = status.value("CpuUsage").toObject();
    double userCpu = cpuUsage.value("User").toDouble();
    double systemCpu = cpuUsage.value("System").toDouble();
    _cpuUsage = userCpu + systemCpu;
    
    // Mesh 數據
    QJsonObject mesh1 = status.value("Mesh1").toObject();
    _unitName = mesh1.value("StatusName").toString();
    _nodeId = mesh1.value("NodeId").toInt();
    
    // 本地解調狀態
    QJsonObject localDemod = mesh1.value("LocalDemodStatus").toObject();
    
    // 獲取陣列
    QJsonArray snrArray = localDemod.value("SNR").toArray();
    QJsonArray sigLevAArray = localDemod.value("sigLevA").toArray();
    QJsonArray sigLevBArray = localDemod.value("sigLevB").toArray();
    
    // 找到有效信號的索引（SNR > 0）
    int validIndex = -1;
    double maxSnr = -3.0;
    
    for (int i = 0; i < snrArray.size(); i++) {
        double snr = snrArray[i].toDouble();
        if (snr > 0.0 && snr > maxSnr) {
            maxSnr = snr;
            validIndex = i;
        }
    }
    
    // 如果找到有效信號，提取對應的 RSSI
    if (validIndex >= 0) {
        _snr = maxSnr;
        _rssiAntennaA = sigLevAArray[validIndex].toDouble();
        _rssiAntennaB = sigLevBArray[validIndex].toDouble();
        _rssiAverage = (_rssiAntennaA + _rssiAntennaB) / 2.0;
        
        qDebug() << "BluSDR:" << _name << "- Valid signal at index" << validIndex
                 << "Temp:" << _temperature << "°C"
                 << "CPU:" << QString::number(_cpuUsage, 'f', 1) << "%"
                 << "RSSI A:" << _rssiAntennaA << "dBm"
                 << "RSSI B:" << _rssiAntennaB << "dBm"
                 << "RSSI Avg:" << _rssiAverage << "dBm"
                 << "SNR:" << _snr << "dB";
    } else {
        // 沒有有效信號，使用背景噪聲
        _snr = -3.0;
        _rssiAntennaA = localDemod.value("sigLevA0").toDouble();
        _rssiAntennaB = localDemod.value("sigLevB0").toDouble();
        _rssiAverage = (_rssiAntennaA + _rssiAntennaB) / 2.0;
        
        qDebug() << "BluSDR:" << _name << "- No valid signal (background noise)"
                 << "Temp:" << _temperature << "°C"
                 << "CPU:" << QString::number(_cpuUsage, 'f', 1) << "%"
                 << "Noise A:" << _rssiAntennaA << "dBm"
                 << "Noise B:" << _rssiAntennaB << "dBm";
    }
    
    _updateLastUpdate();
    emit dataChanged();
}

void BluSDRDevice::_updateTimerFired()
{
    _fetchData();
}

void BluSDRDevice::_setConnected(bool connected)
{
    if (_connected != connected) {
        _connected = connected;
        emit connectedChanged();
        qDebug() << "BluSDR:" << _name << (connected ? "connected" : "disconnected");
    }
}

void BluSDRDevice::_updateLastUpdate()
{
    _lastUpdate = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
}
