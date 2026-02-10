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
    _consecutiveFailures = 0;
    _updateTimer->start();
    _fetchData();
}

void BluSDRDevice::stopMonitoring()
{
    qDebug() << "BluSDR: Stopping monitoring for" << _name;
    _updateTimer->stop();

    // ⭐ 取消當前請求
    if (_currentReply) {
        qDebug() << "BluSDR: Aborting current request for" << _name;

        // ⭐ 先斷開信號
        disconnect(_currentReply, nullptr, this, nullptr);

        _currentReply->abort();
        _currentReply->deleteLater();
        _currentReply = nullptr;
    }

    _consecutiveFailures = 0;
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

    // ⭐ 取消舊請求
    if (_currentReply) {
        // ⭐ 先斷開信號，避免 abort() 觸發回調
        disconnect(_currentReply, nullptr, this, nullptr);

        _currentReply->abort();
        _currentReply->deleteLater();
        _currentReply = nullptr;
    }

    QNetworkRequest statusRequest = _createAuthenticatedRequest("status.json");

    // ⭐ 設定 3 秒超時
    statusRequest.setTransferTimeout(REQUEST_TIMEOUT_MS);

    _currentReply = _networkManager->get(statusRequest);
    connect(_currentReply, &QNetworkReply::finished, this, &BluSDRDevice::_onStatusReplyFinished);
}

void BluSDRDevice::_onStatusReplyFinished()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        return;
    }

    // ⭐ 如果不是當前請求，忽略（雙重保險）
    if (reply != _currentReply) {
        qDebug() << "BluSDR: Ignoring reply from aborted request for" << _name;
        reply->deleteLater();
        return;
    }

    reply->deleteLater();
    _currentReply = nullptr;

    if (reply->error() == QNetworkReply::NoError) {
        // ✅ 請求成功
        _parseStatusJson(reply->readAll());
        _consecutiveFailures = 0;
        _setConnected(true);
    } else {
        // ❌ 請求失敗
        _consecutiveFailures++;

        qWarning() << "BluSDR: Error fetching status from" << _name
                   << "(" << _consecutiveFailures << "/" << MAX_FAILURES_BEFORE_DISCONNECT << ")"
                   << ":" << reply->errorString();

        if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
            qWarning() << "BluSDR: Authentication failed for" << _name;
        }

        // ⭐ 連續失敗 3 次才判定為斷線
        if (_consecutiveFailures >= MAX_FAILURES_BEFORE_DISCONNECT) {
            _setConnected(false);
        }
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

    double outputAtten = mesh1.value("OutputAtten").toDouble();
    _setOutputAttenuation(outputAtten);

    int currentCfg = root.value("Status").toObject().value("CurrentConfig").toInt(1);
    _setCurrentConfig(currentCfg);

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
        qDebug() << "BluSDR:" << _name << (connected ? "✅ connected" : "❌ disconnected");
    }
}

void BluSDRDevice::_updateLastUpdate()
{
    _lastUpdate = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
}

void BluSDRDevice::setOutputAttenuation(double attenuation, int configNum)
{
    // 驗證範圍
    if (attenuation < 0.0 || attenuation > 32.0) {
        qWarning() << "BluSDR: Invalid attenuation value:" << attenuation
                   << "(must be 0-32 dB)";
        emit attenuationSetFailed(QString("Attenuation must be between 0 and 32 dB"));
        return;
    }

    if (configNum < 1 || configNum > 16) {
        qWarning() << "BluSDR: Invalid config number:" << configNum
                   << "(must be 1-16)";
        emit attenuationSetFailed(QString("Config number must be between 1 and 16"));
        return;
    }

    _setSettingAttenuation(true);

            // 建立 JSON 請求
    QJsonObject modulation;
    modulation["OutputAtten"] = attenuation;

    QJsonObject mesh1;
    mesh1["Modulation"] = modulation;

    QJsonObject config;
    config["Mesh1"] = mesh1;

    QJsonObject root;
    root[QString("Config%1").arg(configNum)] = config;

    QJsonDocument doc(root);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);

            // 發送 POST 請求
    QNetworkRequest request = _createAuthenticatedRequest("cfgs.cgi");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply* reply = _networkManager->post(request, jsonData);

    connect(reply, &QNetworkReply::finished,
            this, &BluSDRDevice::_onAttenuationReplyFinished);

    qDebug() << "BluSDR: Setting output attenuation to" << attenuation
             << "dB on config" << configNum;
}

void BluSDRDevice::_onAttenuationReplyFinished()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    reply->deleteLater();
    _setSettingAttenuation(false);

    if (reply->error() == QNetworkReply::NoError) {
        qDebug() << "BluSDR: Successfully set output attenuation";
        emit attenuationSetSuccess(_outputAttenuation);

                // 立即重新讀取以確認
        QTimer::singleShot(500, this, &BluSDRDevice::refreshData);
    } else {
        QString errorMsg = QString("Failed to set attenuation: %1")
        .arg(reply->errorString());
        qWarning() << "BluSDR:" << errorMsg;
        emit attenuationSetFailed(errorMsg);
    }
}

void BluSDRDevice::refreshAttenuation()
{
    refreshData();
}

void BluSDRDevice::_setOutputAttenuation(double value)
{
    if (qAbs(_outputAttenuation - value) > 0.01) {
        _outputAttenuation = value;
        emit outputAttenuationChanged();
    }
}

void BluSDRDevice::_setCurrentConfig(int config)
{
    if (_currentConfig != config) {
        _currentConfig = config;
        emit currentConfigChanged();
    }
}

void BluSDRDevice::_setSettingAttenuation(bool setting)
{
    if (_settingAttenuation != setting) {
        _settingAttenuation = setting;
        emit settingAttenuationChanged();
    }
}
