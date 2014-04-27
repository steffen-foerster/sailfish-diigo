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

OTHER_FILES += harbour-marker.desktop \
    translations/*.ts \
    rpm/harbour-marker.yaml \
    rpm/harbour-marker.spec \
    rpm/harbour-marker.changes.in \
    qml/cover/CoverPage.qml \
    qml/harbour-marker.qml \
    qml/components/MessageBookmarkList.qml \
    qml/components/LabelText.qml \
    qml/pages/HttpClient.js \
    qml/pages/Settings.js \
    qml/pages/LocalStore.js \
    qml/pages/AppState.js \
    qml/pages/Utils.js \
    qml/pages/ServicePage.qml \
    qml/pages/diigo/ViewBookmarkPage.qml \
    qml/pages/diigo/StartPage.qml \
    qml/pages/diigo/SettingPage.qml \
    qml/pages/diigo/SearchPage.qml \
    qml/pages/diigo/AddBookmarkPage.qml \
    qml/pages/diigo/DiigoService.js \
    qml/pages/pinboard/PinboardService.js \
    qml/pages/pinboard/SettingPage.qml \
    qml/pages/pinboard/StartPage.qml \
    qml/pages/pinboard/SearchPage.qml \
    qml/pages/pinboard/ViewBookmarkPage.qml \
    qml/pages/pinboard/AddBookmarkPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-marker-de.ts

HEADERS += \
    src/config.h \
    src/sail_util.h
