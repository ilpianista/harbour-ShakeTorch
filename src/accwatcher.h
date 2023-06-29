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

class QSensorGesture;

class AccWatcher : public QObject
{
    Q_OBJECT
public:
    explicit AccWatcher(QObject *parent = 0);
    virtual ~AccWatcher();

private Q_SLOTS:
    void accChanged();

private:
    QSensorGesture *m_shake;
};

#endif // ACCWATCHER_H
