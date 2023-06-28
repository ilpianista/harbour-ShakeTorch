# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-shaketorch

QT += sensors dbus

CONFIG += qt

SOURCES += src/ShakeTorch.cpp \
    src/accwatcher.cpp

DISTFILES += rpm/harbour-shaketorch.changes \
    rpm/harbour-shaketorch.service \
    rpm/harbour-shaketorch.spec

HEADERS += \
    src/accwatcher.h

TARGETPATH = /usr/bin
target.path = $$TARGETPATH

INSTALLS += target
