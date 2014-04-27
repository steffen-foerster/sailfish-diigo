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
TARGET = harbour-marker

CONFIG += sailfishapp

SOURCES += src/harbour-marker.cpp \
    src/sail_util.cpp \

OTHER_FILES += qml/harbour-marker.qml \
    qml/cover/CoverPage.qml \
    translations/*.ts \
    qml/pages/SettingPage.qml \
    qml/pages/StartPage.qml \
    qml/pages/HttpClient.js \
    qml/pages/DiigoService.js \
    qml/pages/Settings.js \
    qml/pages/LocalStore.js \
    qml/components/MessageBookmarkList.qml \
    qml/pages/AddBookmarkPage.qml \
    qml/pages/AppState.js \
    qml/pages/Utils.js \
    qml/pages/SearchPage.qml \
    rpm/harbour-marker.yaml \
    rpm/harbour-marker.spec \
    rpm/harbour-marker.changes.in \
    qml/harbour-marker.qml \
    harbour-marker.desktop \
    qml/pages/ViewBookmarkPage.qml \
    qml/components/LabelText.qml \
    qml/pages/diigo/Settings.js \
    qml/pages/diigo/ViewBookmarkPage.qml \
    qml/pages/diigo/StartPage.qml \
    qml/pages/diigo/SettingPage.qml \
    qml/pages/diigo/SearchPage.qml \
    qml/pages/diigo/AddBookmarkPage.qml \
    qml/pages/diigo/DiigoService.js \
    qml/pages/ServicePage.qml \
    qml/pages/diigo/PinboardService.js

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-marker-de.ts

HEADERS += \
    src/config.h \
    src/sail_util.h

