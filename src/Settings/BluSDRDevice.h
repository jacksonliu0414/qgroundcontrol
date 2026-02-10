#pragma once

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QTimer>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtQmlIntegration/QtQmlIntegration>

class BluSDRDevice : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("BluSDRDevice should not be created directly")

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString ipAddress READ ipAddress WRITE setIpAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)

    Q_PROPERTY(double rssiAverage READ rssiAverage NOTIFY dataChanged)
    Q_PROPERTY(double rssiAntennaA READ rssiAntennaA NOTIFY dataChanged)
    Q_PROPERTY(double rssiAntennaB READ rssiAntennaB NOTIFY dataChanged)
    Q_PROPERTY(double snr READ snr NOTIFY dataChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY dataChanged)
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY dataChanged)
    Q_PROPERTY(QString lastUpdate READ lastUpdate NOTIFY dataChanged)
    Q_PROPERTY(QString unitName READ unitName NOTIFY dataChanged)
    Q_PROPERTY(int nodeId READ nodeId NOTIFY dataChanged)

    Q_PROPERTY(double outputAttenuation READ outputAttenuation NOTIFY outputAttenuationChanged)
    Q_PROPERTY(int currentConfig READ currentConfig NOTIFY currentConfigChanged)
    Q_PROPERTY(bool settingAttenuation READ settingAttenuation NOTIFY settingAttenuationChanged)

   public:
    explicit BluSDRDevice(const QString& name, const QString& ipAddress, QObject* parent = nullptr);
    ~BluSDRDevice();

    QString name() const { return _name; }
    QString ipAddress() const { return _ipAddress; }
    bool enabled() const { return _enabled; }
    bool connected() const { return _connected; }
    QString username() const { return _username; }
    QString password() const { return _password; }

    double rssiAverage() const { return _rssiAverage; }
    double rssiAntennaA() const { return _rssiAntennaA; }
    double rssiAntennaB() const { return _rssiAntennaB; }
    double snr() const { return _snr; }
    double temperature() const { return _temperature; }
    double cpuUsage() const { return _cpuUsage; }
    QString lastUpdate() const { return _lastUpdate; }
    QString unitName() const { return _unitName; }
    int nodeId() const { return _nodeId; }

    double outputAttenuation() const { return _outputAttenuation; }
    int currentConfig() const { return _currentConfig; }
    bool settingAttenuation() const { return _settingAttenuation; }

    Q_INVOKABLE void setOutputAttenuation(double attenuation, int configNum = 1);
    Q_INVOKABLE void refreshAttenuation();

    void setName(const QString& name);
    void setIpAddress(const QString& ip);
    void setEnabled(bool enabled);
    void setUsername(const QString& username);
    void setPassword(const QString& password);

    Q_INVOKABLE void startMonitoring();
    Q_INVOKABLE void stopMonitoring();
    Q_INVOKABLE void refreshData();

   signals:
    void nameChanged();
    void ipAddressChanged();
    void enabledChanged();
    void connectedChanged();
    void usernameChanged();
    void passwordChanged();
    void dataChanged();
    void errorOccurred(const QString& error);
    void outputAttenuationChanged();
    void currentConfigChanged();
    void settingAttenuationChanged();
    void attenuationSetSuccess(double value);
    void attenuationSetFailed(const QString& error);

   private slots:
    void _onStatusReplyFinished();
    void _updateTimerFired();

   private:
    void _fetchData();
    void _parseStatusJson(const QByteArray& data);
    void _setConnected(bool connected);
    void _updateLastUpdate();
    QNetworkRequest _createAuthenticatedRequest(const QString& endpoint);

    QString _name;
    QString _ipAddress;
    QString _username = "admin";
    QString _password = "Eastwood";
    bool _enabled = false;
    bool _connected = false;

    double _rssiAverage = 0.0;
    double _rssiAntennaA = 0.0;
    double _rssiAntennaB = 0.0;
    double _snr = 0.0;
    double _temperature = 0.0;
    double _cpuUsage = 0.0;
    QString _lastUpdate;
    QString _unitName;
    int _nodeId = 0;

    QNetworkAccessManager* _networkManager = nullptr;
    QTimer* _updateTimer = nullptr;

    // ⭐ 新增：當前請求和失敗計數
    QNetworkReply* _currentReply = nullptr;
    int _consecutiveFailures = 0;

    static constexpr int UPDATE_INTERVAL_MS = 1000;
    static constexpr int REQUEST_TIMEOUT_MS = 3000;
    static constexpr int MAX_FAILURES_BEFORE_DISCONNECT = 3;  // ⭐ 新增常數

    double _outputAttenuation = 0.0;
    int _currentConfig = 1;
    bool _settingAttenuation = false;

    void _onAttenuationReplyFinished();
    void _setOutputAttenuation(double value);
    void _setCurrentConfig(int config);
    void _setSettingAttenuation(bool setting);
};
