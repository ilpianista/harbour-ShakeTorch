qm.input    = TRANSLATIONS
qm.output   = $$OUT_PWD/translations/${QMAKE_FILE_BASE}.qm
qm.commands = @echo "compiling ${QMAKE_FILE_NAME}"; \
                lrelease -removeidentical -idbased -silent ${QMAKE_FILE_NAME} -qm ${QMAKE_FILE_OUT}
qm.CONFIG   = target_predeps no_link

QMAKE_EXTRA_COMPILERS += qm

translations.files = $$OUT_PWD/translations/*.qm
translations.path  = /usr/share/translations
translations.CONFIG += no_check_exist

INSTALLS += translations
