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
#include <QDBusConnection>
#include <QDBusInterface>
#include <QSensorGestureManager>

#include "accwatcher.h"

static const QString FLASHLIGHT_SERVICE("com.jolla.settings.system.flashlight");
static const QString FLASHLIGHT_PATH("/com/jolla/settings/system/flashlight");
static const QString FLASHLIGHT_INTERFACE(FLASHLIGHT_SERVICE);

AccWatcher::AccWatcher(QObject *parent) :
    QObject(parent),
    m_shake(0),
    m_iface(0)
{
    m_iface = new QDBusInterface(FLASHLIGHT_SERVICE, FLASHLIGHT_PATH, FLASHLIGHT_INTERFACE, QDBusConnection::sessionBus(), this);

    QSensorGestureManager manager;
    if (manager.gestureIds().contains("QtSensors.shake")) {
        m_shake = new QSensorGesture(QStringList("QtSensors.shake"), this);
        m_shake->startDetection();
        connect(m_shake, SIGNAL(shake()), this, SLOT(accChanged()));
    }
}

AccWatcher::~AccWatcher()
{
    delete m_shake;
    delete m_iface;
}

void AccWatcher::accChanged()
{
    if (m_iface->isValid()) {
        QDBusMessage reply = m_iface->call("toggleFlashlight");

        if (reply.type() == QDBusMessage::ErrorMessage) {
            qDebug() << reply.errorName() << reply.errorMessage();
        }
    }
}
