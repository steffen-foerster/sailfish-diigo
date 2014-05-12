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
    qml/harbour-marker.qml \
    qml/components/MessageBookmarkList.qml \
    qml/components/LabelText.qml \
    qml/pages/HttpClient.js \
    qml/pages/Settings.js \
    qml/pages/LocalStore.js \
    qml/pages/Utils.js \
    qml/pages/ServicePage.qml \
    qml/cover/CoverPageInactive.qml \
    qml/cover/CoverPageActive.qml \
    qml/pages/MainPage.qml \
    qml/pages/SignInPage.qml \
    qml/services/ServiceManager.qml \
    qml/components/BookmarkView.qml \
    qml/components/TagsView.qml \
    qml/js/Bookmark.js \
    qml/pages/SearchDialog.qml \
    qml/pages/pinboard/SettingDialog.qml \
    qml/pages/diigo/SettingDialog.qml \
    qml/pages/AddDialog.qml \
    qml/pages/DetailsPage.qml \
    qml/services/PinboardService.js \
    qml/services/DiigoService.js \
    qml/js/Utils.js \
    qml/js/Settings.js \
    qml/js/LocalStore.js \
    qml/js/HttpClient.js \
    qml/pages/EditDialog.qml \
    qml/services/Importer.js \
    qml/pages/ImportPage.qml \
    qml/services/Services.js \
    qml/services/LocalService.js \
    qml/pages/local/SettingDialog.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-marker-de.ts

HEADERS += \
    src/config.h \
    src/sail_util.h

