TEMPLATE = app

TARGET = harbour-warehouse
target.path = $$INSTALL_ROOT/usr/bin

QT += network dbus

CONFIG += sailfishapp
CONFIG += link_pkgconfig
PKGCONFIG += packagekit-qt5 sailfishapp

DEFINES += QT_USE_FAST_CONCATENATION QT_USE_FAST_OPERATOR_PLUS
DEFINES += Q_OS_SAILFISH

packagesExist(sailfishapp) {
#special cases?
}

####################DEPLOYMENT SETTINGS###################
qml.files = qml
qml.path = $$INSTALL_ROOT/usr/share/harbour-warehouse

desktop.files = harbour-warehouse.desktop
desktop.path = $$INSTALL_ROOT/usr/share/applications

icon.files = harbour-warehouse.png
icon.path = $$INSTALL_ROOT/usr/share/icons/hicolor/86x86/apps

#dbus.files = dbus/net.thecust.harbour_warehouse.service
#dbus.path = /usr/share/dbus-1/services

zypp.files = rpm/openrepos.enabled
zypp.path = $$INSTALL_ROOT/etc/zypp/repos.d

INSTALLS += zypp target qml desktop icon #dbus

INCLUDEPATH += $PWD/src

HEADERS += \
    src/apptranslator.h \
    src/packagekitproxy.h \
    src/qmlthreadworker.h \
    src/cache.h

SOURCES += src/main.cpp \
    src/apptranslator.cpp \
    src/packagekitproxy.cpp \
    src/qmlthreadworker.cpp \
    src/cache.cpp

#dbus
#HEADERS += src/dbus_service.h
#SOURCES += src/dbus_service.cpp

OTHER_FILES += \
    rpm/harbour-warehouse.spec \
    rpm/harbour-warehouse.yaml \
    rpm/openrepos.enabled

OTHER_FILES += \
    harbour-warehouse.desktop \
    qml/*

############## translations settings ##################
lupdate_only {
    SOURCES = qml/main-sailfish.qml \
        qml/main-harmattan.qml \
        qml/components/*.qml \
        qml/components-jolla/*.qml \
        qml/pages/*.qml \
        qml/pages-jolla/*.qml \
        qml/js/*.js
}
