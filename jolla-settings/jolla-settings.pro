TEMPLATE = aux

settings-entry.path = /usr/share/jolla-settings/entries
settings-entry.files = entries/shaketorch.json

settings-ui.path = /usr/share/jolla-settings/pages/shaketorch
settings-ui.files = pages/shaketorch/mainpage.qml\
                    pages/shaketorch/EnableSwitch.qml

INSTALLS += settings-ui settings-entry

lupdate_only {
    SOURCES += pages/*/*.qml
}

TRANSLATIONS += translations/settings-shaketorch.ts \
                translations/settings-shaketorch-de.ts

include(translations/translations.pri)
