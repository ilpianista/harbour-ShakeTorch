TARGET = harbour-shaketorch

QT += sensors dbus

CONFIG += qt

SOURCES += ShakeTorch.cpp \
           accwatcher.cpp

HEADERS += \
    accwatcher.h

TARGETPATH = /usr/bin
target.path = $$TARGETPATH

INSTALLS += target
