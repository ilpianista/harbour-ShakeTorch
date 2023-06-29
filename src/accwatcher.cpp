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

#include <QDebug>
#include <QDBusReply>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QSensorGestureManager>

#include "accwatcher.h"

static const QString FLASHLIGHT_SERVICE("com.jolla.settings.system.flashlight");
static const QString FLASHLIGHT_PATH("/com/jolla/settings/system/flashlight");
static const QString FLASHLIGHT_INTERFACE(FLASHLIGHT_SERVICE);

AccWatcher::AccWatcher(QObject *parent) :
    QObject(parent),
    m_shake(0)
{
    QSensorGestureManager manager;
    if (manager.gestureIds().contains("QtSensors.shake")) {
        m_shake = new QSensorGesture(QStringList("QtSensors.shake"), this);
        m_shake->startDetection();
        connect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));
    } else {
        qDebug() << "QtSensors.shake gesture is missing";
    }
}

AccWatcher::~AccWatcher()
{
    delete m_shake;
}

void AccWatcher::accChanged()
{
    qDebug() << "shaken!";

    // Let's prevent the slot to be invoked twice until we've done
    disconnect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));

    // Check wheather the service is already active or not
    QDBusInterface dbus("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", QDBusConnection::sessionBus(), this);
    if (!dbus.isValid()) {
        qDebug() << "Unable to get dbus iface";
    }

    QDBusReply<bool> reply = dbus.call("NameHasOwner", FLASHLIGHT_SERVICE);
    if (!reply.isValid()) {
        qDebug() << "DBus NameHasOwner call failed with" << reply.error().name() << ":" << reply.error().message();
    }

    // Start the dbus service
    if (!reply.value()) {
        QDBusPendingCall call = dbus.asyncCall("StartServiceByName", FLASHLIGHT_SERVICE, uint(0));
        call.waitForFinished();
    }

    QDBusInterface iface(FLASHLIGHT_SERVICE, FLASHLIGHT_PATH, FLASHLIGHT_INTERFACE, QDBusConnection::sessionBus(), this);
    if (!iface.isValid()) {
        qDebug() << "Unable to get flashlight iface";
    } else {
        QDBusMessage reply = iface.call("toggleFlashlight");
        if (reply.type() == QDBusMessage::ErrorMessage) {
            qDebug() << "DBus toggleFlashlight failed with" << reply.errorName() << ":" << reply.errorMessage();
        }
    }

    connect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));
}
