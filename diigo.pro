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
TARGET = diigo

CONFIG += sailfishapp

SOURCES += src/diigo.cpp \
    src/sail_util.cpp

OTHER_FILES += qml/diigo.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SecondPage.qml \
    rpm/diigo.changes.in \
    rpm/diigo.spec \
    rpm/diigo.yaml \
    translations/*.ts \
    diigo.desktop \
    qml/pages/SettingPage.qml \
    qml/pages/StartPage.qml \
    qml/pages/HttpClient.js \
    qml/pages/DiigoService.js \
    qml/pages/Settings.js \
    qml/components/BookmarkItem.qml \
    qml/pages/LocalStore.js \
    qml/components/MessageBookmarkList.qml \
    qml/pages/AddBookmarkPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/diigo-de.ts

HEADERS += \
    src/config.h \
    src/sail_util.h

