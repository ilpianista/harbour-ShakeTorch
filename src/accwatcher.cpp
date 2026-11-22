/*
    Copyright (C) 2023 Andrea Scarpino <andrea@scarpino.dev>
    All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDebug>
#include <QSensorGestureManager>

#include "accwatcher.h"

static const QString FLASHLIGHT_SERVICE("com.jolla.settings.system.flashlight");
static const QString FLASHLIGHT_PATH("/com/jolla/settings/system/flashlight");
static const QString FLASHLIGHT_INTERFACE(FLASHLIGHT_SERVICE);

static const QString SETTING_TURN_ON("turnOnOnShake");
static const QString SETTING_TURN_OFF("turnOffOnShake");

AccWatcher::AccWatcher(QObject *parent)
    : QObject(parent)
    , m_shake(0)
{
    QSensorGestureManager manager;
    if (manager.gestureIds().contains("QtSensors.shake")) {
        m_shake = new QSensorGesture(QStringList("QtSensors.shake"), this);
        m_shake->startDetection();
        connect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));
        qInfo() << "Connected to shake gesture";
    } else
        qCritical() << "QtSensors.shake gesture is missing";

    if (QDBusConnection::sessionBus().connect(
                    FLASHLIGHT_SERVICE,
                    FLASHLIGHT_PATH,
                    FLASHLIGHT_INTERFACE,
                    QStringLiteral("flashlightOnChanged"), "b",
                    this, SLOT(flashStateChanged(bool)))) {
        qInfo() << "Connected to flashlight change signal";
    } else
        qCritical() << "Could not connect flashlight change signal";

    m_config = new MDConfGroup(QStringLiteral("/apps/%1/%2")
                    .arg(parent->property("organizationName").toString())
                    .arg(parent->property("applicationName").toString())
                    );

    connect(m_config, SIGNAL(valuesChanged()), this, SLOT(updateSettings()));
    connect(m_config, SIGNAL(valueChanged(const QString&)), this, SLOT(updateSetting(const QString&)));
    updateSettings();
}

AccWatcher::~AccWatcher()
{
    delete m_shake;
    delete m_config;
}

void AccWatcher::flashStateChanged(bool on)
{
    qInfo() << "flashlight changed to" << (on ? "on" : "off");
    if (m_isOn != on)
        m_isOn = on;
}

void AccWatcher::accChanged()
{
    qDebug() << "shaken!";

    // Let's prevent the slot to be invoked twice until we've done
    disconnect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));

    // Check wheather the service is already active or not
    QDBusInterface dbus("org.freedesktop.DBus",
                        "/org/freedesktop/DBus",
                        "org.freedesktop.DBus",
                        QDBusConnection::sessionBus(),
                        this);
    if (!dbus.isValid()) {
        qCritical() << "Unable to get dbus iface";
    }

    QDBusReply<bool> reply = dbus.call("NameHasOwner", FLASHLIGHT_SERVICE);
    if (!reply.isValid()) {
        qDebug() << "DBus NameHasOwner call failed with" << reply.error().name() << ":"
                 << reply.error().message();
    }

    // Start the dbus service
    if (!reply.value()) {
        QDBusPendingCall call = dbus.asyncCall("StartServiceByName", FLASHLIGHT_SERVICE, uint(0));
        call.waitForFinished();
    }

    QDBusInterface iface(FLASHLIGHT_SERVICE, FLASHLIGHT_PATH, FLASHLIGHT_INTERFACE);
    if ( iface.isValid() && ((m_isOn && m_turnOff) || (!m_isOn && m_turnOn)) ) {
        QDBusPendingCall call =  iface.asyncCall("toggleFlashlight");
    }

    connect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));
}

void AccWatcher::updateSetting(const QString& key)
{
    Q_UNUSED(key);
    updateSettings();
}

void AccWatcher::updateSettings()
{
    if (m_config == nullptr) return;
    m_turnOn  = m_config->value(SETTING_TURN_ON,  true).toBool();
    m_turnOff = m_config->value(SETTING_TURN_OFF, true).toBool();
    qInfo() << "Read Settings from:" << m_config->path()
            << "\nTurn on on shake:" << m_turnOn
            << "\nTurn off on shake:" << m_turnOff << "\n";

}
