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

#ifndef ACCWATCHER_H
#define ACCWATCHER_H

#include <QObject>
#include <mlite5/MDConfGroup>

class QSensorGesture;

class AccWatcher : public QObject
{
    Q_OBJECT
public:
    explicit AccWatcher(QObject *parent = 0);
    virtual ~AccWatcher();

    void setConfig(const QVariantMap config);

private Q_SLOTS:
    void accChanged();
    void flashStateChanged(bool);
    void updateSettings();
    void updateSetting(const QString& key);

private:
    bool m_turnOn;
    bool m_turnOff;
    QSensorGesture *m_shake;
    MDConfGroup* m_config = nullptr;

    bool m_isOn;
};

#endif // ACCWATCHER_H
